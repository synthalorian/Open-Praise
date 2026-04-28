import 'package:flutter_test/flutter_test.dart';
import 'package:open_praise/features/pdf_import/chord_heuristic.dart';

void main() {
  group('isChordLine', () {
    test('accepts a line of simple chord tokens', () {
      expect(ChordHeuristic.isChordLine('G  D  Em  C'), isTrue);
    });

    test('accepts chords with slash bass', () {
      expect(ChordHeuristic.isChordLine('G/B  D/F#  Em'), isTrue);
    });

    test('accepts extended chord types', () {
      expect(ChordHeuristic.isChordLine('Cmaj7  Dsus4  Am7  F#m7b5'), isTrue);
    });

    test('rejects a plain lyric line', () {
      expect(
        ChordHeuristic.isChordLine('Amazing grace how sweet the sound'),
        isFalse,
      );
    });

    test('rejects a mostly-lyric line with a single chord-looking token', () {
      expect(
        ChordHeuristic.isChordLine('A saved a wretch like me there now'),
        isFalse,
      );
    });

    test('rejects empty string', () {
      expect(ChordHeuristic.isChordLine(''), isFalse);
      expect(ChordHeuristic.isChordLine('   '), isFalse);
    });
  });

  group('mergeChordOverLyric', () {
    test('inserts chords at the correct columns', () {
      const chords = 'G        D         Em         C';
      const lyric = 'Amazing grace how sweet the sound';
      final merged = ChordHeuristic.mergeChordOverLyric(chords, lyric);
      expect(merged, startsWith('[G]Amazing'));
      expect(merged, contains('[D]'));
      expect(merged, contains('[Em]'));
      expect(merged, contains('[C]'));
    });

    test('handles lyric shorter than chord-line rightmost column', () {
      const chords = 'G         D';
      const lyric = 'Hi';
      final merged = ChordHeuristic.mergeChordOverLyric(chords, lyric);
      expect(merged, contains('[G]'));
      expect(merged, contains('[D]'));
    });
  });

  group('chordOnlyLine', () {
    test('wraps each chord in brackets', () {
      expect(ChordHeuristic.chordOnlyLine('G D Em C'),
          '[G] [D] [Em] [C]');
    });
  });

  group('textToChordPro', () {
    test('infers title and emits directives', () {
      const raw = '''
Amazing Grace
Key of G
Tempo: 72

G        D         Em        C
Amazing grace how sweet the sound
''';
      final out = ChordHeuristic.textToChordPro(raw);
      expect(out, contains('{title: Amazing Grace}'));
      expect(out, contains('{key: G}'));
      expect(out, contains('{tempo: 72}'));
      expect(out, contains('[G]Amazing'));
    });

    test('emits section markers for known headers', () {
      const raw = '''
Verse 1
G        D
Amazing grace

Chorus
C        G
My chains are gone
''';
      final out = ChordHeuristic.textToChordPro(raw);
      expect(out, contains('{start_of_verse}'));
      expect(out, contains('{start_of_chorus}'));
    });

    test('passes through chord-only instrumental lines', () {
      const raw = '''
Song

G D Em C

Some lyrics here
''';
      final out = ChordHeuristic.textToChordPro(raw);
      expect(out, contains('[G] [D] [Em] [C]'));
    });
  });
}
