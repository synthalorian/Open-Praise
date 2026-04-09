import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/chord_engine/models.dart';
import '../features/chord_engine/parser.dart';
import '../data/hive_store.dart';

// ══════════════════════════════════════════════════════════
//  SONG LIBRARY PROVIDER
// ══════════════════════════════════════════════════════════

class SongLibraryNotifier extends StateNotifier<List<Song>> {
  SongLibraryNotifier() : super(HiveStore.getAllSongs());

  void refresh() => state = HiveStore.getAllSongs();

  Future<Song> importFromChordPro(String rawContent) async {
    final song = ChordProParser.parse(rawContent).copyWith(rawContent: rawContent);
    await HiveStore.saveSong(song);
    refresh();
    return song;
  }

  Future<Song> updateFromChordPro(String id, String rawContent) async {
    final parsed = ChordProParser.parse(rawContent);
    final song = parsed.copyWith(id: id, rawContent: rawContent);
    await HiveStore.saveSong(song);
    refresh();
    return song;
  }

  Future<void> deleteSong(String id) async {
    await HiveStore.deleteSong(id);
    refresh();
  }

  Future<void> updateSong(Song song) async {
    await HiveStore.saveSong(song);
    refresh();
  }
}

final songLibraryProvider =
    StateNotifierProvider<SongLibraryNotifier, List<Song>>((ref) {
  return SongLibraryNotifier();
});

// ══════════════════════════════════════════════════════════
//  SETLIST PROVIDER
// ══════════════════════════════════════════════════════════

class SetlistNotifier extends StateNotifier<List<Setlist>> {
  SetlistNotifier() : super(HiveStore.getAllSetlists());

  void refresh() => state = HiveStore.getAllSetlists();

  Future<Setlist> createSetlist(String name) async {
    final setlist = Setlist(name: name, songIds: []);
    await HiveStore.saveSetlist(setlist);
    refresh();
    return setlist;
  }

  Future<void> deleteSetlist(String id) async {
    await HiveStore.deleteSetlist(id);
    refresh();
  }

  Future<void> addSongToSetlist(String setlistId, String songId) async {
    final setlist = HiveStore.getSetlist(setlistId);
    if (setlist == null) return;
    final updated = setlist.copyWith(songIds: [...setlist.songIds, songId]);
    await HiveStore.saveSetlist(updated);
    refresh();
  }

  Future<void> removeSongFromSetlist(String setlistId, String songId) async {
    final setlist = HiveStore.getSetlist(setlistId);
    if (setlist == null) return;
    final ids = List<String>.from(setlist.songIds)..remove(songId);
    await HiveStore.saveSetlist(setlist.copyWith(songIds: ids));
    refresh();
  }

  Future<void> reorderSongs(String setlistId, int oldIndex, int newIndex) async {
    final setlist = HiveStore.getSetlist(setlistId);
    if (setlist == null) return;
    final ids = List<String>.from(setlist.songIds);
    if (newIndex > oldIndex) newIndex--;
    final item = ids.removeAt(oldIndex);
    ids.insert(newIndex, item);
    await HiveStore.saveSetlist(setlist.copyWith(songIds: ids));
    refresh();
  }

  Future<void> renameSetlist(String setlistId, String newName) async {
    final setlist = HiveStore.getSetlist(setlistId);
    if (setlist == null) return;
    await HiveStore.saveSetlist(setlist.copyWith(name: newName));
    refresh();
  }
}

final setlistProvider =
    StateNotifierProvider<SetlistNotifier, List<Setlist>>((ref) {
  return SetlistNotifier();
});

// ══════════════════════════════════════════════════════════
//  ACTIVE SETLIST + PERFORMANCE STATE
// ══════════════════════════════════════════════════════════

class PerformanceState {
  final Setlist? activeSetlist;
  final int currentSongIndex;
  final int transposeOffset;

  const PerformanceState({
    this.activeSetlist,
    this.currentSongIndex = 0,
    this.transposeOffset = 0,
  });

  PerformanceState copyWith({
    Setlist? activeSetlist,
    int? currentSongIndex,
    int? transposeOffset,
  }) {
    return PerformanceState(
      activeSetlist: activeSetlist ?? this.activeSetlist,
      currentSongIndex: currentSongIndex ?? this.currentSongIndex,
      transposeOffset: transposeOffset ?? this.transposeOffset,
    );
  }

  String? get currentSongId {
    if (activeSetlist == null) return null;
    if (currentSongIndex < 0 ||
        currentSongIndex >= activeSetlist!.songIds.length) return null;
    return activeSetlist!.songIds[currentSongIndex];
  }

  Song? get currentSong {
    final id = currentSongId;
    if (id == null) return null;
    return HiveStore.getSong(id);
  }

  int get songCount => activeSetlist?.songIds.length ?? 0;
  bool get hasPrevious => currentSongIndex > 0;
  bool get hasNext =>
      activeSetlist != null &&
      currentSongIndex < activeSetlist!.songIds.length - 1;
}

class PerformanceNotifier extends StateNotifier<PerformanceState> {
  PerformanceNotifier() : super(const PerformanceState());

  void loadSetlist(Setlist setlist) {
    state = PerformanceState(activeSetlist: setlist, currentSongIndex: 0, transposeOffset: 0);
  }

  void nextSong() {
    if (state.hasNext) {
      state = state.copyWith(
        currentSongIndex: state.currentSongIndex + 1,
        transposeOffset: 0,
      );
    }
  }

  void previousSong() {
    if (state.hasPrevious) {
      state = state.copyWith(
        currentSongIndex: state.currentSongIndex - 1,
        transposeOffset: 0,
      );
    }
  }

  void goToSong(int index) {
    if (index >= 0 && index < state.songCount) {
      state = state.copyWith(currentSongIndex: index, transposeOffset: 0);
    }
  }

  void transposeUp() {
    state = state.copyWith(transposeOffset: (state.transposeOffset + 1) % 12);
  }

  void transposeDown() {
    state = state.copyWith(transposeOffset: (state.transposeOffset - 1) % 12);
  }

  void setTranspose(int offset) {
    state = state.copyWith(transposeOffset: offset % 12);
  }

  void resetTranspose() {
    state = state.copyWith(transposeOffset: 0);
  }
}

final performanceProvider =
    StateNotifierProvider<PerformanceNotifier, PerformanceState>((ref) {
  return PerformanceNotifier();
});
