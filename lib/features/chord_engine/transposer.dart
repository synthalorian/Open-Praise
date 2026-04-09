import 'models.dart';

class ChordTransposer {
  static const List<String> sharpNotes = [
    'C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'
  ];
  static const List<String> flatNotes = [
    'C', 'Db', 'D', 'Eb', 'E', 'F', 'Gb', 'G', 'Ab', 'A', 'Bb', 'B'
  ];

  /// Transpose a song by a semitone offset
  static Song transposeSong(Song song, int semitones) {
    if (semitones == 0) return song;

    final transposedSections = song.sections.map((section) {
      final transposedLines = section.lines.map((line) {
        return transposeLine(line, semitones);
      }).toList();
      return SongSection(title: section.title, lines: transposedLines);
    }).toList();

    return Song(
      title: song.title,
      artist: song.artist,
      key: song.key != null ? transposeChord(song.key!, semitones) : null,
      sections: transposedSections,
    );
  }

  /// Transpose chords in a single line of text
  static String transposeLine(String line, int semitones) {
    final chordRegex = RegExp(r'\[(.*?)\]');
    return line.replaceAllMapped(chordRegex, (match) {
      final chord = match.group(1)!;
      return '[${transposeChord(chord, semitones)}]';
    });
  }

  /// Transpose a single chord string (e.g., "G", "C#m7", "F/A")
  static String transposeChord(String chord, int semitones) {
    // Handle bass notes (e.g., C/E)
    if (chord.contains('/')) {
      final parts = chord.split('/');
      return '${transposeChord(parts[0], semitones)}/${transposeChord(parts[1], semitones)}';
    }

    // Extract root and suffix
    final rootMatch = RegExp(r'^([A-G][#b]?)').firstMatch(chord);
    if (rootMatch == null) return chord;

    final root = rootMatch.group(1)!;
    final suffix = chord.substring(root.length);

    // Find the current note index
    int index = sharpNotes.indexOf(root);
    if (index == -1) index = flatNotes.indexOf(root);
    if (index == -1) return chord; // Not found

    // Calculate new index
    int newIndex = (index + semitones) % 12;
    if (newIndex < 0) newIndex += 12;

    // Use sharps for now (can add logic later for flats depending on target key)
    final newRoot = sharpNotes[newIndex];
    return '$newRoot$suffix';
  }
}
