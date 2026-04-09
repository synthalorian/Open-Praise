import 'package:hive_flutter/hive_flutter.dart';
import '../features/chord_engine/models.dart';

/// Initializes Hive, registers adapters, and opens boxes.
class HiveStore {
  static const String songBoxName = 'songs';
  static const String setlistBoxName = 'setlists';
  static const String settingsBoxName = 'settings';

  static late Box<Song> songBox;
  static late Box<Setlist> setlistBox;
  static late Box settingsBox;

  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(ChordAdapter());
    Hive.registerAdapter(SongSectionAdapter());
    Hive.registerAdapter(SongAdapter());
    Hive.registerAdapter(SetlistAdapter());

    // Open boxes
    songBox = await Hive.openBox<Song>(songBoxName);
    setlistBox = await Hive.openBox<Setlist>(setlistBoxName);
    settingsBox = await Hive.openBox(settingsBoxName);
  }

  // ── Songs ──────────────────────────────────────────────
  static List<Song> getAllSongs() => songBox.values.toList();

  static Song? getSong(String id) {
    try {
      return songBox.values.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveSong(Song song) async {
    await songBox.put(song.id, song);
  }

  static Future<void> deleteSong(String id) async {
    await songBox.delete(id);
  }

  // ── Setlists ──────────────────────────────────────────
  static List<Setlist> getAllSetlists() => setlistBox.values.toList();

  static Setlist? getSetlist(String id) {
    try {
      return setlistBox.values.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveSetlist(Setlist setlist) async {
    await setlistBox.put(setlist.id, setlist);
  }

  static Future<void> deleteSetlist(String id) async {
    await setlistBox.delete(id);
  }

  // ── Settings ──────────────────────────────────────────
  static T? getSetting<T>(String key, {T? defaultValue}) {
    return settingsBox.get(key, defaultValue: defaultValue) as T?;
  }

  static Future<void> setSetting<T>(String key, T value) async {
    await settingsBox.put(key, value);
  }
}
