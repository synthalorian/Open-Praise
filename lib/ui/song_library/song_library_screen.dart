import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/chord_engine/models.dart';
import '../../features/pdf_import/pdf_chord_extractor.dart';
import '../../providers/app_providers.dart';
import '../theme.dart';
import '../chord_sheet_view.dart';
import '../pdf_import/pdf_import_preview_screen.dart';

class SongLibraryScreen extends ConsumerWidget {
  const SongLibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songs = ref.watch(songLibraryProvider);
    final theme = AppTheme.of(context);

    return Scaffold(
      backgroundColor: theme.bg,
      appBar: theme.appBar('SONG LIBRARY', actions: [
        IconButton(
          icon: Icon(Icons.picture_as_pdf, color: theme.secondary),
          tooltip: 'Import PDF',
          onPressed: () => _importFromPdf(context, ref),
        ),
        IconButton(
          icon: Icon(Icons.file_open, color: theme.tertiary),
          tooltip: 'Import ChordPro file',
          onPressed: () => _importFromFile(context, ref),
        ),
        IconButton(
          icon: Icon(Icons.add, color: theme.secondary),
          tooltip: 'Paste ChordPro',
          onPressed: () => _showImportDialog(context, ref),
        ),
      ]),
      body: songs.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.music_off, size: 64, color: theme.muted),
                  const SizedBox(height: 16),
                  Text('NO SONGS IN LIBRARY',
                      style: TextStyle(
                          color: theme.muted,
                          letterSpacing: 2,
                          fontSize: 14)),
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    onPressed: () => _showImportDialog(context, ref),
                    icon: const Icon(Icons.add),
                    label: const Text('IMPORT CHORDPRO'),
                    style: theme.neonButton(theme.secondary),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: songs.length,
              itemBuilder: (context, index) {
                final song = songs[index];
                return _SongTile(song: song);
              },
            ),
    );
  }

  Future<void> _importFromFile(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: true,
    );
    if (result == null || result.files.isEmpty) return;

    int imported = 0;
    for (final file in result.files) {
      if (file.path == null) continue;
      try {
        final content = await File(file.path!).readAsString();
        await ref.read(songLibraryProvider.notifier).importFromChordPro(content);
        imported++;
      } catch (e) {
        debugPrint('Failed to import ${file.name}: $e');
      }
    }

    if (context.mounted && imported > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Imported $imported song${imported == 1 ? "" : "s"}'),
          backgroundColor: AppTheme.of(context).surface,
        ),
      );
    }
  }

  Future<void> _importFromPdf(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result == null || result.files.isEmpty) return;
    final path = result.files.first.path;
    if (path == null) return;

    // Kick extraction with a loading dialog.
    if (!context.mounted) return;
    final theme = AppTheme.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: theme.surface,
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: theme.primary),
            const SizedBox(width: 16),
            Text('EXTRACTING…',
                style: theme.heading.copyWith(fontSize: 14)),
          ],
        ),
      ),
    );

    PdfExtractionResult extraction;
    try {
      extraction = await PdfChordExtractor.extract(File(path));
    } catch (e) {
      if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF import failed: $e'),
            backgroundColor: theme.surface,
          ),
        );
      }
      return;
    }

    if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
    if (!context.mounted) return;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PdfImportPreviewScreen(
          sourcePath: path,
          extraction: extraction,
        ),
      ),
    );
  }

  void _showImportDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    final theme = AppTheme.of(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.surface,
        title: Text('IMPORT CHORDPRO',
            style: theme.heading.copyWith(fontSize: 16)),
        content: SizedBox(
          width: 500,
          height: 300,
          child: TextField(
            controller: controller,
            maxLines: null,
            expands: true,
            style: theme.mono.copyWith(fontSize: 13),
            decoration: InputDecoration(
              hintText:
                  'Paste ChordPro content here...\n\n{title: Amazing Grace}\n{key: G}\n[G]Amazing [C]grace...',
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
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('CANCEL', style: TextStyle(color: theme.muted)),
          ),
          OutlinedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                ref
                    .read(songLibraryProvider.notifier)
                    .importFromChordPro(controller.text);
                Navigator.pop(ctx);
              }
            },
            style: theme.neonButton(theme.secondary),
            child: const Text('IMPORT'),
          ),
        ],
      ),
    );
  }
}

class _SongTile extends ConsumerWidget {
  final Song song;

  const _SongTile({required this.song});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = AppTheme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: theme.neonBorder(),
      child: ListTile(
        leading: Icon(Icons.music_note, color: theme.primary),
        title: Text(song.title,
            style: theme.mono.copyWith(fontWeight: FontWeight.bold)),
        subtitle: Text(
          [
            if (song.artist != null) song.artist!,
            if (song.key != null) 'Key: ${song.key}',
            if (song.capo != null) 'Capo: ${song.capo}',
            if (song.tempo != null) '${song.tempo} BPM',
          ].join(' · '),
          style: TextStyle(color: theme.muted, fontSize: 12),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          onPressed: () {
            ref.read(songLibraryProvider.notifier).deleteSong(song.id);
          },
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => _SongPreviewScreen(song: song),
            ),
          );
        },
      ),
    );
  }
}

class _SongPreviewScreen extends ConsumerWidget {
  final Song song;

  const _SongPreviewScreen({required this.song});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = AppTheme.of(context);
    return Scaffold(
      backgroundColor: theme.bg,
      appBar: theme.appBar(song.title.toUpperCase(), actions: [
        if (song.rawContent != null)
          IconButton(
            icon: Icon(Icons.edit, color: theme.tertiary),
            tooltip: 'Edit ChordPro',
            onPressed: () => _showEditDialog(context, ref),
          ),
      ]),
      body: ChordSheetView(song: song),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(text: song.rawContent ?? '');
    final theme = AppTheme.of(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.surface,
        title:
            Text('EDIT CHORDPRO', style: theme.heading.copyWith(fontSize: 16)),
        content: SizedBox(
          width: 500,
          height: 400,
          child: TextField(
            controller: controller,
            maxLines: null,
            expands: true,
            style: theme.mono.copyWith(fontSize: 13),
            decoration: InputDecoration(
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
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('CANCEL', style: TextStyle(color: theme.muted)),
          ),
          OutlinedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                ref
                    .read(songLibraryProvider.notifier)
                    .updateFromChordPro(song.id, controller.text);
                Navigator.pop(ctx);
                Navigator.pop(context);
              }
            },
            style: theme.neonButton(theme.tertiary),
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
  }
}
