import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/hive_store.dart';
import '../../features/chord_engine/models.dart';
import '../../features/chord_engine/transposer.dart';
import '../../providers/app_providers.dart';
import '../../providers/sync_provider.dart';
import '../theme.dart';
import '../chord_sheet_view.dart';

class PerformanceScreen extends ConsumerStatefulWidget {
  const PerformanceScreen({super.key});

  @override
  ConsumerState<PerformanceScreen> createState() => _PerformanceScreenState();
}

class _PerformanceScreenState extends ConsumerState<PerformanceScreen> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleKey(KeyEvent event) {
    if (event is! KeyDownEvent) return;

    final perf = ref.read(performanceProvider.notifier);
    final sync = ref.read(syncProvider.notifier);
    final syncState = ref.read(syncProvider);

    switch (event.logicalKey) {
      case LogicalKeyboardKey.space:
      case LogicalKeyboardKey.arrowRight:
        perf.nextSong();
        if (syncState.role == SyncRole.leader) sync.broadcastState();
        break;
      case LogicalKeyboardKey.arrowLeft:
        perf.previousSong();
        if (syncState.role == SyncRole.leader) sync.broadcastState();
        break;
      case LogicalKeyboardKey.keyT:
        _showTransposeOverlay();
        break;
      case LogicalKeyboardKey.arrowUp:
        perf.transposeUp();
        if (syncState.role == SyncRole.leader) sync.broadcastState();
        break;
      case LogicalKeyboardKey.arrowDown:
        perf.transposeDown();
        if (syncState.role == SyncRole.leader) sync.broadcastState();
        break;
      case LogicalKeyboardKey.digit0:
        perf.resetTranspose();
        break;
      case LogicalKeyboardKey.keyS:
        // Show setlist overview
        _showSetlistDrawer();
        break;
      default:
        break;
    }
  }

  void _showTransposeOverlay() {
    final perf = ref.read(performanceProvider);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: NeonTheme.surface,
        title: Text('TRANSPOSE', style: NeonTheme.heading.copyWith(fontSize: 16)),
        content: Text(
          'Current offset: ${perf.transposeOffset > 0 ? "+${perf.transposeOffset}" : "${perf.transposeOffset}"}\n\n'
          '↑ / ↓  to transpose\n'
          '0  to reset',
          style: NeonTheme.mono,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CLOSE', style: TextStyle(color: NeonTheme.muted)),
          ),
        ],
      ),
    );
  }

  void _showSetlistDrawer() {
    final perf = ref.read(performanceProvider);
    final setlist = perf.activeSetlist;
    if (setlist == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: NeonTheme.surface,
      builder: (ctx) => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: setlist.songIds.length,
        itemBuilder: (_, index) {
          final songId = setlist.songIds[index];
          final song = HiveStore.getSong(songId);
          final songTitle = song?.title ?? songId;
          final isActive = index == perf.currentSongIndex;

          return ListTile(
            leading: Text(
              '${index + 1}',
              style: NeonTheme.heading.copyWith(
                fontSize: 18,
                color: isActive ? NeonTheme.neonCyan : NeonTheme.neonGreen,
              ),
            ),
            title: Text(
              songTitle,
              style: NeonTheme.mono.copyWith(
                color: isActive ? NeonTheme.neonCyan : NeonTheme.text,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            tileColor: isActive ? NeonTheme.neonCyan.withValues(alpha:0.1) : null,
            onTap: () {
              ref.read(performanceProvider.notifier).goToSong(index);
              Navigator.pop(ctx);
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final perf = ref.watch(performanceProvider);
    final syncState = ref.watch(syncProvider);
    final song = perf.currentSong;

    // Apply transposition
    final displaySong = song != null && perf.transposeOffset != 0
        ? ChordTransposer.transposeSong(song, perf.transposeOffset)
        : song;

    return KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: _handleKey,
      child: Scaffold(
        backgroundColor: NeonTheme.bg,
        appBar: AppBar(
          backgroundColor: NeonTheme.bg,
          elevation: 0,
          iconTheme: const IconThemeData(color: NeonTheme.neonGreen),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displaySong?.title.toUpperCase() ?? 'NO SONG',
                style: NeonTheme.heading.copyWith(fontSize: 14),
              ),
              Row(
                children: [
                  if (displaySong?.key != null)
                    Text('KEY: ${displaySong!.key}  ',
                        style: const TextStyle(
                            color: NeonTheme.neonPink, fontSize: 11)),
                  if (perf.transposeOffset != 0)
                    Text(
                      'T:${perf.transposeOffset > 0 ? "+${perf.transposeOffset}" : "${perf.transposeOffset}"}  ',
                      style: const TextStyle(
                          color: NeonTheme.neonCyan, fontSize: 11),
                    ),
                  Text(
                    '${perf.currentSongIndex + 1}/${perf.songCount}',
                    style: const TextStyle(color: NeonTheme.muted, fontSize: 11),
                  ),
                  if (syncState.isConnected) ...[
                    const SizedBox(width: 8),
                    Icon(Icons.wifi_tethering,
                        size: 12, color: NeonTheme.neonCyan),
                  ],
                ],
              ),
            ],
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(2),
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                color: NeonTheme.neonGreen,
                boxShadow: [
                  BoxShadow(
                      color: NeonTheme.neonGreen,
                      blurRadius: 4,
                      spreadRadius: 1),
                ],
              ),
            ),
          ),
        ),
        body: displaySong == null
            ? const Center(
                child: Text('NO SONG LOADED',
                    style: TextStyle(color: NeonTheme.muted, letterSpacing: 2)),
              )
            : ChordSheetView(song: displaySong),
        bottomNavigationBar: Container(
          color: NeonTheme.bg,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Previous
              IconButton(
                icon: const Icon(Icons.skip_previous, size: 32),
                color: perf.hasPrevious ? NeonTheme.neonGreen : NeonTheme.muted,
                onPressed: perf.hasPrevious
                    ? () {
                        ref.read(performanceProvider.notifier).previousSong();
                        if (syncState.role == SyncRole.leader) {
                          ref.read(syncProvider.notifier).broadcastState();
                        }
                      }
                    : null,
              ),
              // Transpose down
              IconButton(
                icon: const Icon(Icons.remove),
                color: NeonTheme.neonPink,
                onPressed: () {
                  ref.read(performanceProvider.notifier).transposeDown();
                },
              ),
              // Transpose display
              GestureDetector(
                onTap: () =>
                    ref.read(performanceProvider.notifier).resetTranspose(),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: NeonTheme.neonBorder(NeonTheme.neonCyan),
                  child: Text(
                    perf.transposeOffset == 0
                        ? 'ORIG'
                        : '${perf.transposeOffset > 0 ? "+" : ""}${perf.transposeOffset}',
                    style: NeonTheme.mono
                        .copyWith(color: NeonTheme.neonCyan, fontSize: 16),
                  ),
                ),
              ),
              // Transpose up
              IconButton(
                icon: const Icon(Icons.add),
                color: NeonTheme.neonPink,
                onPressed: () {
                  ref.read(performanceProvider.notifier).transposeUp();
                },
              ),
              // Next
              IconButton(
                icon: const Icon(Icons.skip_next, size: 32),
                color: perf.hasNext ? NeonTheme.neonGreen : NeonTheme.muted,
                onPressed: perf.hasNext
                    ? () {
                        ref.read(performanceProvider.notifier).nextSong();
                        if (syncState.role == SyncRole.leader) {
                          ref.read(syncProvider.notifier).broadcastState();
                        }
                      }
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
