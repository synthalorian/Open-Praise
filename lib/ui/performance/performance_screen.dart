import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/hive_store.dart';
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
        _showSetlistDrawer();
        break;
      default:
        break;
    }
  }

  void _showTransposeOverlay() {
    final perf = ref.read(performanceProvider);
    final theme = AppTheme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.surface,
        title:
            Text('TRANSPOSE', style: theme.heading.copyWith(fontSize: 16)),
        content: Text(
          'Current offset: ${perf.transposeOffset > 0 ? "+${perf.transposeOffset}" : "${perf.transposeOffset}"}\n\n'
          '↑ / ↓  to transpose\n'
          '0  to reset',
          style: theme.mono,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('CLOSE', style: TextStyle(color: theme.muted)),
          ),
        ],
      ),
    );
  }

  void _showSetlistDrawer() {
    final perf = ref.read(performanceProvider);
    final setlist = perf.activeSetlist;
    if (setlist == null) return;
    final theme = AppTheme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.surface,
      builder: (ctx) => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: setlist.songIds.length,
        itemBuilder: (_, index) {
          final songId = setlist.songIds[index];
          final song = HiveStore.getSong(songId);
          final songTitle = song?.title ?? songId;
          final isActive = index == perf.currentSongIndex;
          final activeColor = theme.tertiary;

          return ListTile(
            leading: Text(
              '${index + 1}',
              style: theme.heading.copyWith(
                fontSize: 18,
                color: isActive ? activeColor : theme.primary,
              ),
            ),
            title: Text(
              songTitle,
              style: theme.mono.copyWith(
                color: isActive ? activeColor : theme.text,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            tileColor:
                isActive ? activeColor.withValues(alpha: 0.1) : null,
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
    final theme = AppTheme.of(context);

    final displaySong = song != null && perf.transposeOffset != 0
        ? ChordTransposer.transposeSong(song, perf.transposeOffset)
        : song;

    return KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: _handleKey,
      child: Scaffold(
        backgroundColor: theme.bg,
        appBar: AppBar(
          backgroundColor: theme.bg,
          elevation: 0,
          iconTheme: IconThemeData(color: theme.primary),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displaySong?.title.toUpperCase() ?? 'NO SONG',
                style: theme.heading.copyWith(fontSize: 14),
              ),
              Row(
                children: [
                  if (displaySong?.key != null)
                    Text('KEY: ${displaySong!.key}  ',
                        style: TextStyle(
                            color: theme.secondary, fontSize: 11)),
                  if (perf.transposeOffset != 0)
                    Text(
                      'T:${perf.transposeOffset > 0 ? "+${perf.transposeOffset}" : "${perf.transposeOffset}"}  ',
                      style: TextStyle(
                          color: theme.tertiary, fontSize: 11),
                    ),
                  Text(
                    '${perf.currentSongIndex + 1}/${perf.songCount}',
                    style: TextStyle(color: theme.muted, fontSize: 11),
                  ),
                  if (syncState.isConnected) ...[
                    const SizedBox(width: 8),
                    Icon(Icons.wifi_tethering,
                        size: 12, color: theme.tertiary),
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
                color: theme.primary,
                boxShadow: [
                  BoxShadow(
                      color: theme.primary
                          .withValues(alpha: theme.glowStrength),
                      blurRadius: 4,
                      spreadRadius: 1),
                ],
              ),
            ),
          ),
        ),
        body: displaySong == null
            ? Center(
                child: Text('NO SONG LOADED',
                    style:
                        TextStyle(color: theme.muted, letterSpacing: 2)),
              )
            : ChordSheetView(song: displaySong),
        bottomNavigationBar: Container(
          color: theme.bg,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.skip_previous, size: 32),
                color: perf.hasPrevious ? theme.primary : theme.muted,
                onPressed: perf.hasPrevious
                    ? () {
                        ref.read(performanceProvider.notifier).previousSong();
                        if (syncState.role == SyncRole.leader) {
                          ref.read(syncProvider.notifier).broadcastState();
                        }
                      }
                    : null,
              ),
              IconButton(
                icon: const Icon(Icons.remove),
                color: theme.secondary,
                onPressed: () {
                  ref.read(performanceProvider.notifier).transposeDown();
                },
              ),
              GestureDetector(
                onTap: () =>
                    ref.read(performanceProvider.notifier).resetTranspose(),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: theme.neonBorder(theme.tertiary),
                  child: Text(
                    perf.transposeOffset == 0
                        ? 'ORIG'
                        : '${perf.transposeOffset > 0 ? "+" : ""}${perf.transposeOffset}',
                    style: theme.mono
                        .copyWith(color: theme.tertiary, fontSize: 16),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                color: theme.secondary,
                onPressed: () {
                  ref.read(performanceProvider.notifier).transposeUp();
                },
              ),
              IconButton(
                icon: const Icon(Icons.skip_next, size: 32),
                color: perf.hasNext ? theme.primary : theme.muted,
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
