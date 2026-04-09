import 'package:flutter_test/flutter_test.dart';
import 'package:open_praise/features/chord_engine/transposer.dart';
import 'package:open_praise/features/chord_engine/models.dart';

void main() {
  group('ChordTransposer.transposeChord', () {
    test('transposes simple chords up', () {
      expect(ChordTransposer.transposeChord('C', 2), equals('D'));
      expect(ChordTransposer.transposeChord('G', 2), equals('A'));
      expect(ChordTransposer.transposeChord('B', 1), equals('C'));
    });

    test('transposes minor chords', () {
      expect(ChordTransposer.transposeChord('Em', 1), equals('Fm'));
      expect(ChordTransposer.transposeChord('Am', 3), equals('Cm'));
    });

    test('transposes chords with extensions', () {
      expect(ChordTransposer.transposeChord('C#m7', 1), equals('Dm7'));
      expect(ChordTransposer.transposeChord('Gmaj7', 2), equals('Amaj7'));
      expect(ChordTransposer.transposeChord('Dsus4', 2), equals('Esus4'));
    });

    test('transposes slash chords', () {
      expect(ChordTransposer.transposeChord('F/A', 1), equals('F#/A#'));
      expect(ChordTransposer.transposeChord('C/E', 2), equals('D/F#'));
      expect(ChordTransposer.transposeChord('G/B', 5), equals('C/E'));
    });

    test('transposes down (negative semitones)', () {
      expect(ChordTransposer.transposeChord('D', -2), equals('C'));
      expect(ChordTransposer.transposeChord('C', -1), equals('B'));
      expect(ChordTransposer.transposeChord('F', -5), equals('C'));
    });

    test('transposes flat chords (output uses sharps)', () {
      expect(ChordTransposer.transposeChord('Bb', 2), equals('C'));
      expect(ChordTransposer.transposeChord('Eb', 1), equals('E'));
      // Transposer normalizes to sharps — Db+2 = D# (not Eb)
      expect(ChordTransposer.transposeChord('Db', 2), equals('D#'));
    });

    test('zero semitones returns same chord', () {
      expect(ChordTransposer.transposeChord('G', 0), equals('G'));
      expect(ChordTransposer.transposeChord('Am7', 0), equals('Am7'));
    });

    test('wraps around correctly', () {
      // Full octave = same note
      expect(ChordTransposer.transposeChord('C', 12), equals('C'));
      expect(ChordTransposer.transposeChord('G', -12), equals('G'));
    });

    test('returns non-chord strings unchanged', () {
      expect(ChordTransposer.transposeChord('N.C.', 2), equals('N.C.'));
      expect(ChordTransposer.transposeChord('', 2), equals(''));
    });
  });

  group('ChordTransposer.transposeLine', () {
    test('transposes all chords in a line', () {
      expect(
        ChordTransposer.transposeLine('[G]Amazing [C]grace', 2),
        equals('[A]Amazing [D]grace'),
      );
    });

    test('handles lines with no chords', () {
      expect(
        ChordTransposer.transposeLine('Just lyrics here', 2),
        equals('Just lyrics here'),
      );
    });

    test('handles multiple chords inline', () {
      expect(
        ChordTransposer.transposeLine('[C][G][Am][F]', 2),
        equals('[D][A][Bm][G]'),
      );
    });

    test('handles slash chords in brackets', () {
      expect(
        ChordTransposer.transposeLine('[C/E]Bass note', 2),
        equals('[D/F#]Bass note'),
      );
    });
  });

  group('ChordTransposer.transposeSong', () {
    test('transposes entire song', () {
      final song = Song(
        title: 'Test Song',
        key: 'G',
        sections: [
          SongSection(title: 'Verse', lines: ['[G]Amazing [C]grace']),
        ],
      );

      final transposed = ChordTransposer.transposeSong(song, 2);

      expect(transposed.key, equals('A'));
      expect(transposed.sections[0].lines[0], equals('[A]Amazing [D]grace'));
    });

    test('zero transpose returns same song', () {
      final song = Song(
        title: 'Test Song',
        key: 'G',
        sections: [
          SongSection(title: 'Verse', lines: ['[G]Line']),
        ],
      );

      final result = ChordTransposer.transposeSong(song, 0);
      expect(identical(result, song), isTrue);
    });

    test('preserves song metadata', () {
      final song = Song(
        title: 'My Song',
        artist: 'My Artist',
        key: 'C',
        sections: [
          SongSection(title: 'Verse', lines: ['[C]Hello']),
        ],
      );

      final transposed = ChordTransposer.transposeSong(song, 3);
      expect(transposed.title, equals('My Song'));
      expect(transposed.artist, equals('My Artist'));
      expect(transposed.key, equals('D#'));
    });

    test('handles song with null key', () {
      final song = Song(
        title: 'No Key',
        sections: [
          SongSection(title: 'Verse', lines: ['[G]Line']),
        ],
      );

      final transposed = ChordTransposer.transposeSong(song, 2);
      expect(transposed.key, isNull);
      expect(transposed.sections[0].lines[0], equals('[A]Line'));
    });

    test('transposes multiple sections', () {
      final song = Song(
        title: 'Multi',
        key: 'G',
        sections: [
          SongSection(title: 'Verse', lines: ['[G]Verse line']),
          SongSection(title: 'Chorus', lines: ['[C]Chorus line', '[D]Another']),
        ],
      );

      final transposed = ChordTransposer.transposeSong(song, 2);
      expect(transposed.sections[0].lines[0], equals('[A]Verse line'));
      expect(transposed.sections[1].lines[0], equals('[D]Chorus line'));
      expect(transposed.sections[1].lines[1], equals('[E]Another'));
    });
  });
}
