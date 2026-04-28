import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/chord_engine/models.dart';
import '../../features/chord_engine/parser.dart';
import '../../features/pdf_import/pdf_chord_extractor.dart';
import '../../providers/app_providers.dart';
import '../chord_sheet_view.dart';
import '../theme.dart';

/// Two-pane view: on the left the heuristic-generated ChordPro (editable),
/// on the right a live preview rendered through the existing chord sheet view.
class PdfImportPreviewScreen extends ConsumerStatefulWidget {
  final String sourcePath;
  final PdfExtractionResult extraction;

  const PdfImportPreviewScreen({
    super.key,
    required this.sourcePath,
    required this.extraction,
  });

  @override
  ConsumerState<PdfImportPreviewScreen> createState() =>
      _PdfImportPreviewScreenState();
}

class _PdfImportPreviewScreenState
    extends ConsumerState<PdfImportPreviewScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.extraction.chordPro);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final previewSong = ChordProParser.parse(_controller.text);
    final sourceLabel = switch (widget.extraction.source) {
      PdfExtractionSource.embeddedText => 'EMBEDDED TEXT',
      PdfExtractionSource.ocr => 'OCR',
      PdfExtractionSource.mixed => 'MIXED',
    };

    return Scaffold(
      backgroundColor: theme.bg,
      appBar: theme.appBar('PDF IMPORT // PREVIEW', actions: [
        IconButton(
          icon: Icon(Icons.refresh, color: theme.tertiary),
          tooltip: 'Re-run heuristic',
          onPressed: () {
            setState(() {
              _controller.text = widget.extraction.chordPro;
            });
          },
        ),
        IconButton(
          icon: Icon(Icons.check, color: theme.primary),
          tooltip: 'Save to library',
          onPressed: () => _save(context),
        ),
      ]),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: theme.surface,
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 14, color: theme.tertiary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Source: $sourceLabel  ·  ${widget.extraction.pageCount} page${widget.extraction.pageCount == 1 ? "" : "s"}'
                    '${widget.extraction.warning != null ? "  ·  ${widget.extraction.warning}" : ""}',
                    style: TextStyle(
                        color: theme.muted,
                        fontFamily: theme.monoFont,
                        fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth > 700;
                final editor = _Editor(controller: _controller,
                    onChanged: () => setState(() {}));
                final preview = _Preview(song: previewSong);
                if (wide) {
                  return Row(
                    children: [
                      Expanded(child: editor),
                      VerticalDivider(
                          width: 1,
                          color: theme.primary.withValues(alpha: 0.2)),
                      Expanded(child: preview),
                    ],
                  );
                }
                return DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      TabBar(
                        labelColor: theme.primary,
                        unselectedLabelColor: theme.muted,
                        indicatorColor: theme.primary,
                        tabs: const [
                          Tab(text: 'EDIT'),
                          Tab(text: 'PREVIEW'),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [editor, preview],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save(BuildContext context) async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    await ref
        .read(songLibraryProvider.notifier)
        .importFromChordPro(text);
    if (!context.mounted) return;
    Navigator.of(context).pop();
  }
}

class _Editor extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onChanged;

  const _Editor({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        controller: controller,
        onChanged: (_) => onChanged(),
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        style: theme.mono.copyWith(fontSize: 13, color: theme.text),
        decoration: InputDecoration(
          filled: true,
          fillColor: theme.surface,
          hintText: 'ChordPro source…',
          hintStyle: TextStyle(color: theme.muted, fontSize: 12),
          border: OutlineInputBorder(
            borderSide:
                BorderSide(color: theme.primary.withValues(alpha: 0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: theme.primary.withValues(alpha: 0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: theme.primary),
          ),
        ),
      ),
    );
  }
}

class _Preview extends StatelessWidget {
  final Song song;

  const _Preview({required this.song});

  @override
  Widget build(BuildContext context) {
    return ChordSheetView(song: song);
  }
}
