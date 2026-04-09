// GENERATED-LIKE CODE — hand-written Hive adapters for models.dart
// Avoids build_runner dependency at runtime.

part of 'models.dart';

class ChordAdapter extends TypeAdapter<Chord> {
  @override
  final int typeId = 0;

  @override
  Chord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Chord(
      root: fields[0] as String,
      accidental: fields[1] as String?,
      suffix: fields[2] as String?,
      bass: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Chord obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.root)
      ..writeByte(1)
      ..write(obj.accidental)
      ..writeByte(2)
      ..write(obj.suffix)
      ..writeByte(3)
      ..write(obj.bass);
  }
}

class SongSectionAdapter extends TypeAdapter<SongSection> {
  @override
  final int typeId = 1;

  @override
  SongSection read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SongSection(
      title: fields[0] as String,
      lines: (fields[1] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, SongSection obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.lines);
  }
}

class SongAdapter extends TypeAdapter<Song> {
  @override
  final int typeId = 2;

  @override
  Song read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Song(
      id: fields[7] as String?,
      title: fields[0] as String,
      artist: fields[1] as String?,
      key: fields[2] as String?,
      tempo: fields[3] as int?,
      capo: fields[4] as int?,
      sections: (fields[5] as List).cast<SongSection>(),
      rawContent: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Song obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.artist)
      ..writeByte(2)
      ..write(obj.key)
      ..writeByte(3)
      ..write(obj.tempo)
      ..writeByte(4)
      ..write(obj.capo)
      ..writeByte(5)
      ..write(obj.sections)
      ..writeByte(6)
      ..write(obj.rawContent)
      ..writeByte(7)
      ..write(obj.id);
  }
}

class SetlistAdapter extends TypeAdapter<Setlist> {
  @override
  final int typeId = 3;

  @override
  Setlist read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Setlist(
      id: fields[0] as String?,
      name: fields[1] as String,
      songIds: (fields[2] as List).cast<String>(),
      createdAt: fields[3] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Setlist obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.songIds)
      ..writeByte(3)
      ..write(obj.createdAt);
  }
}
