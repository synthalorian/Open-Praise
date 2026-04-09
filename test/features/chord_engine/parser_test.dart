import 'package:flutter_test/flutter_test.dart';
import 'package:open_praise/features/chord_engine/parser.dart';

void main() {
  group('ChordProParser', () {
    test('parses basic song with title, artist, key', () {
      const raw = '''
{title: Amazing Grace}
{artist: John Newton}
{key: C}

[C]Amazing [F/C]grace! How [C]sweet the sound
That [C]saved a [G]wretch like me!

{start_of_chorus}
[C]My chains are [F]gone
I've [C]been set [G]free
{end_of_chorus}
''';

      final song = ChordProParser.parse(raw);

      expect(song.title, equals('Amazing Grace'));
      expect(song.artist, equals('John Newton'));
      expect(song.key, equals('C'));
      expect(song.sections.length, equals(2));
      expect(song.sections[0].title, equals('Verse'));
      expect(song.sections[1].title, equals('Chorus'));
    });

    test('parses short aliases (t, a, k)', () {
      const raw = '''
{t: Short Title}
{a: Short Artist}
{k: G}
[G]Hello [D]world
''';

      final song = ChordProParser.parse(raw);
      expect(song.title, equals('Short Title'));
      expect(song.artist, equals('Short Artist'));
      expect(song.key, equals('G'));
    });

    test('parses tempo and capo', () {
      const raw = '''
{title: Tempo Test}
{tempo: 120}
{capo: 3}
[C]Line one
''';

      final song = ChordProParser.parse(raw);
      expect(song.tempo, equals(120));
      expect(song.capo, equals(3));
    });

    test('handles named verse sections', () {
      const raw = '''
{title: Verse Test}
{start_of_verse: 1}
[G]First verse
{end_of_verse}
{start_of_verse: 2}
[Am]Second verse
{end_of_verse}
''';

      final song = ChordProParser.parse(raw);
      expect(song.sections.length, equals(2));
      expect(song.sections[0].title, equals('Verse: 1'));
      expect(song.sections[1].title, equals('Verse: 2'));
    });

    test('handles bridge and tab sections', () {
      const raw = '''
{title: Section Test}
{start_of_bridge}
[Em]Bridge line
{end_of_bridge}
{start_of_tab}
e|---0---|
{end_of_tab}
''';

      final song = ChordProParser.parse(raw);
      expect(song.sections.length, equals(2));
      expect(song.sections[0].title, equals('Bridge'));
      expect(song.sections[1].title, equals('Tab'));
    });

    test('handles short section aliases (soc/eoc, sov/eov, sob/eob, sot/eot)', () {
      const raw = '''
{title: Alias Test}
{sov}
[C]Verse
{eov}
{soc}
[G]Chorus
{eoc}
{sob}
[Am]Bridge
{eob}
{sot}
e|---0---|
{eot}
''';

      final song = ChordProParser.parse(raw);
      expect(song.sections.length, equals(4));
      expect(song.sections[0].title, equals('Verse'));
      expect(song.sections[1].title, equals('Chorus'));
      expect(song.sections[2].title, equals('Bridge'));
      expect(song.sections[3].title, equals('Tab'));
    });

    test('parses comments as prefixed lines', () {
      const raw = '''
{title: Comment Test}
{comment: Slow down here}
[C]Line after comment
''';

      final song = ChordProParser.parse(raw);
      expect(song.sections[0].lines[0], equals('# Slow down here'));
      expect(song.sections[0].lines[1], contains('[C]'));
    });

    test('handles ci (italic comment) alias', () {
      const raw = '''
{title: CI Test}
{ci: Instrumental}
[G]Solo
''';

      final song = ChordProParser.parse(raw);
      expect(song.sections[0].lines[0], equals('# Instrumental'));
    });

    test('handles empty input', () {
      final song = ChordProParser.parse('');
      expect(song.title, equals('Untitled Song'));
      expect(song.sections, isEmpty);
    });

    test('handles input with only whitespace lines', () {
      final song = ChordProParser.parse('\n\n   \n\n');
      expect(song.title, equals('Untitled Song'));
      expect(song.sections, isEmpty);
    });

    test('handles song with no directives at all', () {
      const raw = '[G]Just a line with [C]chords\nAnother line';

      final song = ChordProParser.parse(raw);
      expect(song.title, equals('Untitled Song'));
      expect(song.sections.length, equals(1));
      expect(song.sections[0].lines.length, equals(2));
    });

    test('ignores unknown directives', () {
      const raw = '''
{title: Unknown Dir}
{x_custom: something}
[C]Line
''';

      final song = ChordProParser.parse(raw);
      expect(song.title, equals('Unknown Dir'));
      expect(song.sections[0].lines.length, equals(1));
    });

    test('handles invalid tempo gracefully', () {
      const raw = '''
{title: Bad Tempo}
{tempo: notanumber}
[C]Line
''';

      final song = ChordProParser.parse(raw);
      expect(song.tempo, isNull);
    });

    test('consecutive sections without end markers', () {
      const raw = '''
{title: No End}
{start_of_verse}
[G]Verse line
{start_of_chorus}
[C]Chorus line
''';

      final song = ChordProParser.parse(raw);
      expect(song.sections.length, equals(2));
      expect(song.sections[0].title, equals('Verse'));
      expect(song.sections[1].title, equals('Chorus'));
    });
  });
}
