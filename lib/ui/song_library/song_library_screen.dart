import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/chord_engine/models.dart';
import '../../providers/app_providers.dart';
import '../theme.dart';
import '../chord_sheet_view.dart';

class SongLibraryScreen extends ConsumerWidget {
  const SongLibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songs = ref.watch(songLibraryProvider);

    return Scaffold(
      backgroundColor: NeonTheme.bg,
      appBar: NeonTheme.appBar('SONG LIBRARY', actions: [
        IconButton(
          icon: const Icon(Icons.file_open, color: NeonTheme.neonCyan),
          tooltip: 'Import from file',
          onPressed: () => _importFromFile(context, ref),
        ),
        IconButton(
          icon: const Icon(Icons.add, color: NeonTheme.neonPink),
          tooltip: 'Paste ChordPro',
          onPressed: () => _showImportDialog(context, ref),
        ),
      ]),
      body: songs.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.music_off, size: 64, color: NeonTheme.muted),
                  const SizedBox(height: 16),
                  const Text('NO SONGS IN LIBRARY',
                      style: TextStyle(
                          color: NeonTheme.muted,
                          letterSpacing: 2,
                          fontSize: 14)),
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    onPressed: () => _showImportDialog(context, ref),
                    icon: const Icon(Icons.add),
                    label: const Text('IMPORT CHORDPRO'),
                    style: NeonTheme.neonButton(NeonTheme.neonPink),
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
          backgroundColor: NeonTheme.surface,
        ),
      );
    }
  }

  void _showImportDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: NeonTheme.surface,
        title: Text('IMPORT CHORDPRO', style: NeonTheme.heading.copyWith(fontSize: 16)),
        content: SizedBox(
          width: 500,
          height: 300,
          child: TextField(
            controller: controller,
            maxLines: null,
            expands: true,
            style: NeonTheme.mono.copyWith(fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Paste ChordPro content here...\n\n{title: Amazing Grace}\n{key: G}\n[G]Amazing [C]grace...',
              hintStyle: const TextStyle(color: NeonTheme.muted, fontSize: 12),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: NeonTheme.neonGreen.withValues(alpha:0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: NeonTheme.neonGreen.withValues(alpha:0.3)),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: NeonTheme.neonGreen),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL', style: TextStyle(color: NeonTheme.muted)),
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
            style: NeonTheme.neonButton(NeonTheme.neonPink),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: NeonTheme.neonBorder(),
      child: ListTile(
        leading: const Icon(Icons.music_note, color: NeonTheme.neonGreen),
        title: Text(song.title,
            style: NeonTheme.mono.copyWith(fontWeight: FontWeight.bold)),
        subtitle: Text(
          [
            if (song.artist != null) song.artist!,
            if (song.key != null) 'Key: ${song.key}',
            if (song.capo != null) 'Capo: ${song.capo}',
            if (song.tempo != null) '${song.tempo} BPM',
          ].join(' · '),
          style: const TextStyle(color: NeonTheme.muted, fontSize: 12),
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
    return Scaffold(
      backgroundColor: NeonTheme.bg,
      appBar: NeonTheme.appBar(song.title.toUpperCase(), actions: [
        if (song.rawContent != null)
          IconButton(
            icon: const Icon(Icons.edit, color: NeonTheme.neonCyan),
            tooltip: 'Edit ChordPro',
            onPressed: () => _showEditDialog(context, ref),
          ),
      ]),
      body: ChordSheetView(song: song),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(text: song.rawContent ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: NeonTheme.surface,
        title: Text('EDIT CHORDPRO', style: NeonTheme.heading.copyWith(fontSize: 16)),
        content: SizedBox(
          width: 500,
          height: 400,
          child: TextField(
            controller: controller,
            maxLines: null,
            expands: true,
            style: NeonTheme.mono.copyWith(fontSize: 13),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderSide: BorderSide(color: NeonTheme.neonGreen.withValues(alpha:0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: NeonTheme.neonGreen.withValues(alpha:0.3)),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: NeonTheme.neonGreen),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL', style: TextStyle(color: NeonTheme.muted)),
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
            style: NeonTheme.neonButton(NeonTheme.neonCyan),
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
  }
}
