import 'models.dart';

class ChordProParser {
  static Song parse(String content) {
    final List<String> lines = content.split('\n');
    String title = 'Untitled Song';
    String? artist;
    String? key;
    int? tempo;
    int? capo;
    List<SongSection> sections = [];
    String currentSectionTitle = 'Verse';
    List<String> currentSectionLines = [];

    for (var line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      // Directives
      if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
        final inner = trimmed.substring(1, trimmed.length - 1);
        final colonIndex = inner.indexOf(':');
        final command =
            (colonIndex >= 0 ? inner.substring(0, colonIndex) : inner)
                .trim()
                .toLowerCase();
        final value =
            colonIndex >= 0 ? inner.substring(colonIndex + 1).trim() : '';

        switch (command) {
          // Metadata
          case 'title':
          case 't':
            title = value;
            break;
          case 'artist':
          case 'a':
            artist = value;
            break;
          case 'key':
          case 'k':
            key = value;
            break;
          case 'tempo':
            tempo = int.tryParse(value);
            break;
          case 'capo':
            capo = int.tryParse(value);
            break;

          // Section starts
          case 'start_of_chorus':
          case 'soc':
            _flushSection(sections, currentSectionTitle, currentSectionLines);
            currentSectionLines = [];
            currentSectionTitle = 'Chorus';
            break;
          case 'start_of_verse':
          case 'sov':
            _flushSection(sections, currentSectionTitle, currentSectionLines);
            currentSectionLines = [];
            currentSectionTitle = value.isNotEmpty ? 'Verse: $value' : 'Verse';
            break;
          case 'start_of_bridge':
          case 'sob':
            _flushSection(sections, currentSectionTitle, currentSectionLines);
            currentSectionLines = [];
            currentSectionTitle =
                value.isNotEmpty ? 'Bridge: $value' : 'Bridge';
            break;
          case 'start_of_tab':
          case 'sot':
            _flushSection(sections, currentSectionTitle, currentSectionLines);
            currentSectionLines = [];
            currentSectionTitle = 'Tab';
            break;

          // Section ends — flush and reset to Verse
          case 'end_of_chorus':
          case 'eoc':
          case 'end_of_verse':
          case 'eov':
          case 'end_of_bridge':
          case 'eob':
          case 'end_of_tab':
          case 'eot':
            _flushSection(sections, currentSectionTitle, currentSectionLines);
            currentSectionLines = [];
            currentSectionTitle = 'Verse';
            break;

          // Comments (rendered as italic/muted text in the UI)
          case 'comment':
          case 'c':
          case 'ci':
            currentSectionLines.add('# $value');
            break;
        }
      } else {
        // Regular line of text/chords
        currentSectionLines.add(trimmed);
      }
    }

    // Final section cleanup
    _flushSection(sections, currentSectionTitle, currentSectionLines);

    return Song(
      title: title,
      artist: artist,
      key: key,
      tempo: tempo,
      capo: capo,
      sections: sections,
    );
  }

  static void _flushSection(
    List<SongSection> sections,
    String title,
    List<String> lines,
  ) {
    if (lines.isNotEmpty) {
      sections.add(SongSection(title: title, lines: List.from(lines)));
    }
  }
}
