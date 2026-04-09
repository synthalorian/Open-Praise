import 'package:flutter_test/flutter_test.dart';
import 'package:open_praise/features/chord_engine/models.dart';

void main() {
  group('Chord', () {
    test('toString with root only', () {
      final chord = Chord(root: 'C');
      expect(chord.toString(), equals('C'));
    });

    test('toString with accidental', () {
      final chord = Chord(root: 'C', accidental: '#');
      expect(chord.toString(), equals('C#'));
    });

    test('toString with suffix', () {
      final chord = Chord(root: 'A', suffix: 'm7');
      expect(chord.toString(), equals('Am7'));
    });

    test('toString with bass note', () {
      final chord = Chord(root: 'C', bass: 'E');
      expect(chord.toString(), equals('C/E'));
    });

    test('toString with all fields', () {
      final chord = Chord(root: 'C', accidental: '#', suffix: 'm7', bass: 'G');
      expect(chord.toString(), equals('C#m7/G'));
    });
  });

  group('Song', () {
    test('generates id from title', () {
      final song = Song(title: 'Amazing Grace', sections: []);
      expect(song.id, startsWith('amazing_grace_'));
    });

    test('preserves explicit id', () {
      final song = Song(id: 'custom_id', title: 'Test', sections: []);
      expect(song.id, equals('custom_id'));
    });

    test('copyWith preserves fields', () {
      final song = Song(
        title: 'Original',
        artist: 'Artist',
        key: 'G',
        tempo: 120,
        capo: 2,
        sections: [SongSection(title: 'V', lines: ['line'])],
        rawContent: 'raw',
      );

      final copy = song.copyWith(title: 'Modified');
      expect(copy.title, equals('Modified'));
      expect(copy.artist, equals('Artist'));
      expect(copy.key, equals('G'));
      expect(copy.tempo, equals(120));
      expect(copy.capo, equals(2));
      expect(copy.id, equals(song.id));
      expect(copy.rawContent, equals('raw'));
    });

    test('copyWith can override id', () {
      final song = Song(id: 'old', title: 'Test', sections: []);
      final copy = song.copyWith(id: 'new');
      expect(copy.id, equals('new'));
    });
  });

  group('Setlist', () {
    test('generates id automatically', () {
      final setlist = Setlist(name: 'Sunday', songIds: []);
      expect(setlist.id, startsWith('setlist_'));
    });

    test('preserves explicit id', () {
      final setlist = Setlist(id: 'my_id', name: 'Test', songIds: []);
      expect(setlist.id, equals('my_id'));
    });

    test('sets createdAt to now by default', () {
      final before = DateTime.now();
      final setlist = Setlist(name: 'Test', songIds: []);
      final after = DateTime.now();
      expect(setlist.createdAt.isAfter(before.subtract(const Duration(seconds: 1))), isTrue);
      expect(setlist.createdAt.isBefore(after.add(const Duration(seconds: 1))), isTrue);
    });

    test('copyWith preserves fields', () {
      final setlist = Setlist(
        name: 'Sunday Morning',
        songIds: ['song1', 'song2'],
      );

      final copy = setlist.copyWith(name: 'Sunday Evening');
      expect(copy.name, equals('Sunday Evening'));
      expect(copy.songIds, equals(['song1', 'song2']));
      expect(copy.id, equals(setlist.id));
    });

    test('copyWith can modify songIds', () {
      final setlist = Setlist(name: 'Test', songIds: ['a', 'b']);
      final copy = setlist.copyWith(songIds: ['a', 'b', 'c']);
      expect(copy.songIds, equals(['a', 'b', 'c']));
    });
  });
}
