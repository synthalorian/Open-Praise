import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/chord_engine/models.dart';
import '../../data/hive_store.dart';
import '../../providers/app_providers.dart';
import '../theme.dart';
import '../performance/performance_screen.dart';

class SetlistDetailScreen extends ConsumerWidget {
  final String setlistId;

  const SetlistDetailScreen({super.key, required this.setlistId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Re-read setlists so we react to changes
    final setlists = ref.watch(setlistProvider);
    final setlist = setlists.where((s) => s.id == setlistId).firstOrNull;

    if (setlist == null) {
      return Scaffold(
        backgroundColor: NeonTheme.bg,
        appBar: NeonTheme.appBar('SETLIST NOT FOUND'),
        body: const Center(
          child: Text('This setlist has been deleted.',
              style: TextStyle(color: NeonTheme.muted)),
        ),
      );
    }

    final songs = setlist.songIds
        .map((id) => HiveStore.getSong(id))
        .where((s) => s != null)
        .cast<Song>()
        .toList();

    return Scaffold(
      backgroundColor: NeonTheme.bg,
      appBar: NeonTheme.appBar(setlist.name.toUpperCase(), actions: [
        IconButton(
          icon: const Icon(Icons.add, color: NeonTheme.neonPink),
          tooltip: 'Add Song',
          onPressed: () => _showAddSongDialog(context, ref, setlist),
        ),
        IconButton(
          icon: const Icon(Icons.play_arrow, color: NeonTheme.neonCyan),
          tooltip: 'Perform',
          onPressed: songs.isEmpty
              ? null
              : () {
                  ref.read(performanceProvider.notifier).loadSetlist(setlist);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const PerformanceScreen()),
                  );
                },
        ),
      ]),
      body: songs.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.playlist_add, size: 64, color: NeonTheme.muted),
                  const SizedBox(height: 16),
                  const Text('EMPTY SETLIST',
                      style: TextStyle(color: NeonTheme.muted, letterSpacing: 2)),
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    onPressed: () => _showAddSongDialog(context, ref, setlist),
                    icon: const Icon(Icons.add),
                    label: const Text('ADD SONGS'),
                    style: NeonTheme.neonButton(NeonTheme.neonPink),
                  ),
                ],
              ),
            )
          : ReorderableListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: songs.length,
              onReorder: (oldIndex, newIndex) {
                ref
                    .read(setlistProvider.notifier)
                    .reorderSongs(setlistId, oldIndex, newIndex);
              },
              itemBuilder: (context, index) {
                final song = songs[index];
                return Container(
                  key: ValueKey('${song.id}_$index'),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: NeonTheme.neonBorder(),
                  child: ListTile(
                    leading: Text(
                      '${index + 1}',
                      style: NeonTheme.heading.copyWith(fontSize: 20),
                    ),
                    title: Text(song.title,
                        style: NeonTheme.mono
                            .copyWith(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      [
                        if (song.artist != null) song.artist!,
                        if (song.key != null) 'Key: ${song.key}',
                      ].join(' · '),
                      style:
                          const TextStyle(color: NeonTheme.muted, fontSize: 12),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle_outline,
                          color: Colors.redAccent),
                      onPressed: () {
                        ref
                            .read(setlistProvider.notifier)
                            .removeSongFromSetlist(setlistId, song.id);
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showAddSongDialog(
      BuildContext context, WidgetRef ref, Setlist setlist) {
    final allSongs = ref.read(songLibraryProvider);
    final existingIds = setlist.songIds.toSet();

    showModalBottomSheet(
      context: context,
      backgroundColor: NeonTheme.surface,
      builder: (ctx) {
        final available =
            allSongs.where((s) => !existingIds.contains(s.id)).toList();

        if (available.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: Text(
                'No more songs to add.\nImport songs in the Song Library first.',
                textAlign: TextAlign.center,
                style: TextStyle(color: NeonTheme.muted),
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: available.length,
          itemBuilder: (_, index) {
            final song = available[index];
            return ListTile(
              leading:
                  const Icon(Icons.add_circle_outline, color: NeonTheme.neonGreen),
              title: Text(song.title, style: NeonTheme.mono),
              subtitle: Text(song.artist ?? '',
                  style: const TextStyle(color: NeonTheme.muted, fontSize: 12)),
              onTap: () {
                ref
                    .read(setlistProvider.notifier)
                    .addSongToSetlist(setlist.id, song.id);
                Navigator.pop(ctx);
              },
            );
          },
        );
      },
    );
  }
}
