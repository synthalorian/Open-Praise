import 'package:hive/hive.dart';

part 'models.g.dart';

enum KeyType { major, minor }

@HiveType(typeId: 0)
class Chord {
  @HiveField(0)
  final String root;

  @HiveField(1)
  final String? accidental;

  @HiveField(2)
  final String? suffix;

  @HiveField(3)
  final String? bass;

  Chord({required this.root, this.accidental, this.suffix, this.bass});

  @override
  String toString() =>
      '$root${accidental ?? ""}${suffix ?? ""}${bass != null ? "/$bass" : ""}';
}

@HiveType(typeId: 1)
class SongSection {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final List<String> lines;

  SongSection({required this.title, required this.lines});
}

@HiveType(typeId: 2)
class Song {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String? artist;

  @HiveField(2)
  final String? key;

  @HiveField(3)
  final int? tempo;

  @HiveField(4)
  final int? capo;

  @HiveField(5)
  final List<SongSection> sections;

  /// Raw ChordPro source — stored so we can re-parse after edits
  @HiveField(6)
  final String? rawContent;

  /// Unique ID for Hive storage
  @HiveField(7)
  final String id;

  Song({
    String? id,
    required this.title,
    this.artist,
    this.key,
    this.tempo,
    this.capo,
    required this.sections,
    this.rawContent,
  }) : id = id ?? _generateId(title);

  static String _generateId(String title) {
    final slug = title
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]'), '_')
        .replaceAll(RegExp(r'_+'), '_');
    return '${slug}_${DateTime.now().millisecondsSinceEpoch}';
  }

  Song copyWith({
    String? id,
    String? title,
    String? artist,
    String? key,
    int? tempo,
    int? capo,
    List<SongSection>? sections,
    String? rawContent,
  }) {
    return Song(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      key: key ?? this.key,
      tempo: tempo ?? this.tempo,
      capo: capo ?? this.capo,
      sections: sections ?? this.sections,
      rawContent: rawContent ?? this.rawContent,
    );
  }
}

@HiveType(typeId: 3)
class Setlist {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final List<String> songIds;

  @HiveField(3)
  final DateTime createdAt;

  Setlist({
    String? id,
    required this.name,
    required this.songIds,
    DateTime? createdAt,
  })  : id = id ?? 'setlist_${DateTime.now().millisecondsSinceEpoch}',
        createdAt = createdAt ?? DateTime.now();

  Setlist copyWith({
    String? id,
    String? name,
    List<String>? songIds,
    DateTime? createdAt,
  }) {
    return Setlist(
      id: id ?? this.id,
      name: name ?? this.name,
      songIds: songIds ?? this.songIds,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
