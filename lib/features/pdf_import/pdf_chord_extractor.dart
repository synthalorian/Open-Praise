import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart'
    as mlkit;
import 'package:path_provider/path_provider.dart';
import 'package:pdfrx/pdfrx.dart' as pdfrx;
import 'package:syncfusion_flutter_pdf/pdf.dart' as sf;

import 'chord_heuristic.dart';

enum PdfExtractionSource { embeddedText, ocr, mixed }

class PdfExtractionResult {
  final String rawText;
  final String chordPro;
  final PdfExtractionSource source;
  final int pageCount;
  final String? warning;

  const PdfExtractionResult({
    required this.rawText,
    required this.chordPro,
    required this.source,
    required this.pageCount,
    this.warning,
  });
}

/// Orchestrates text extraction from a PDF with OCR fallback for scanned pages.
class PdfChordExtractor {
  /// Minimum characters of embedded text per page below which we assume the
  /// page is scanned and trigger OCR fallback (when available).
  static const int _ocrThreshold = 40;

  /// End-to-end: file → ChordPro source + metadata.
  static Future<PdfExtractionResult> extract(File file) async {
    final bytes = await file.readAsBytes();

    // ── Stage 1: embedded text via Syncfusion ────────────
    final embeddedPages = _extractEmbeddedText(bytes);
    final pageCount = embeddedPages.length;
    final hasRealText =
        embeddedPages.any((p) => p.trim().length >= _ocrThreshold);

    // Fast path — every page has substantial text.
    if (embeddedPages.isNotEmpty &&
        embeddedPages.every((p) => p.trim().length >= _ocrThreshold)) {
      final text = embeddedPages.join('\n\n');
      return PdfExtractionResult(
        rawText: text,
        chordPro: ChordHeuristic.textToChordPro(text),
        source: PdfExtractionSource.embeddedText,
        pageCount: pageCount,
      );
    }

    // ── Stage 2: OCR fallback for sparse pages ────────────
    String? warning;
    final pages = List<String>.from(embeddedPages);

    if (_ocrSupported) {
      try {
        for (int i = 0; i < pages.length; i++) {
          if (pages[i].trim().length >= _ocrThreshold) continue;
          final ocrText = await _ocrPage(file.path, i);
          if (ocrText.trim().isNotEmpty) pages[i] = ocrText;
        }
      } catch (e) {
        warning = 'OCR partially failed: $e';
      }
    } else if (!hasRealText) {
      warning = 'This looks like a scanned PDF. OCR is only available on '
          'Android/iOS in this build — on desktop, please use a PDF with '
          'embedded text, or retry on a mobile device.';
    }

    final text = pages.join('\n\n');
    final source = _ocrSupported && !hasRealText
        ? PdfExtractionSource.ocr
        : (_ocrSupported ? PdfExtractionSource.mixed
                         : PdfExtractionSource.embeddedText);

    return PdfExtractionResult(
      rawText: text,
      chordPro: ChordHeuristic.textToChordPro(text),
      source: source,
      pageCount: pageCount,
      warning: warning,
    );
  }

  // ── Syncfusion text extraction ───────────────────────────
  static List<String> _extractEmbeddedText(Uint8List bytes) {
    final doc = sf.PdfDocument(inputBytes: bytes);
    try {
      final pages = <String>[];
      final extractor = sf.PdfTextExtractor(doc);
      for (int i = 0; i < doc.pages.count; i++) {
        final page = extractor.extractText(
          startPageIndex: i,
          endPageIndex: i,
          layoutText: true,
        );
        pages.add(page);
      }
      return pages;
    } finally {
      doc.dispose();
    }
  }

  // ── OCR via Google ML Kit (mobile only) ─────────────────
  static bool get _ocrSupported {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  static Future<String> _ocrPage(String pdfPath, int pageIndex) async {
    final imagePath = await _rasterizePage(pdfPath, pageIndex);
    try {
      return await _OcrBackend.recognize(imagePath);
    } finally {
      try {
        await File(imagePath).delete();
      } catch (_) {/* best-effort cleanup */}
    }
  }

  /// Render a single PDF page (0-indexed) to PNG on disk; return the path.
  static Future<String> _rasterizePage(String pdfPath, int pageIndex) async {
    final tmpDir = await getTemporaryDirectory();
    final outPath = '${tmpDir.path}/open_praise_ocr_$pageIndex.png';

    final doc = await pdfrx.PdfDocument.openFile(pdfPath);
    try {
      final page = doc.pages[pageIndex];
      final image = await page.render(
        width: (page.width * 2).toInt(),
        height: (page.height * 2).toInt(),
      );
      if (image == null) {
        throw StateError('Failed to rasterize page ${pageIndex + 1}');
      }
      try {
        final uiImage = await image.createImage();
        final data = await uiImage.toByteData(format: ui.ImageByteFormat.png);
        uiImage.dispose();
        if (data == null) {
          throw StateError('PNG encode failed for page ${pageIndex + 1}');
        }
        await File(outPath).writeAsBytes(data.buffer.asUint8List());
      } finally {
        image.dispose();
      }
    } finally {
      doc.dispose();
    }
    return outPath;
  }
}

/// Thin wrapper around `google_mlkit_text_recognition`. Isolated so the
/// backend can be swapped for a desktop OCR (e.g. Tesseract FFI) later without
/// touching the extractor.
class _OcrBackend {
  static Future<String> recognize(String imagePath) async {
    final recognizer =
        mlkit.TextRecognizer(script: mlkit.TextRecognitionScript.latin);
    try {
      final input = mlkit.InputImage.fromFilePath(imagePath);
      final result = await recognizer.processImage(input);
      return result.text;
    } finally {
      await recognizer.close();
    }
  }
}
