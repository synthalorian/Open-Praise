/// Converts chord-over-lyric plain text (like PraiseCharts / Ultimate Guitar
/// exports) into ChordPro inline format.
///
/// Input: lines of text, some containing chord tokens above lyrics
/// Output: ChordPro source with `[Chord]lyric` notation, `{title:…}` directives,
/// and `{start_of_verse}` / `{start_of_chorus}` section markers where possible.
class ChordHeuristic {
  ChordHeuristic._();

  /// Strict chord-token regex — a token that, by itself, reads as a chord.
  /// Matches: G, Am, C#, Bb, G7, Dmaj7, F#m7b5, Csus4, G/B, etc.
  static final RegExp _chordToken = RegExp(
    r'^[A-G](?:#|b)?'
    r'(?:maj|min|m|M|sus|add|dim|aug|\+|°|ø)?'
    r'(?:2|4|5|6|7|9|11|13)?'
    r'(?:sus2|sus4|sus|add2|add4|add9|b5|#5|b9|#9|#11|b13)?'
    r'(?:/[A-G](?:#|b)?)?$',
  );

  /// Directive-line detectors for metadata inference.
  static final RegExp _titleColon =
      RegExp(r'^(?:title|song)\s*[:\-]\s*(.+)$', caseSensitive: false);
  static final RegExp _artistColon =
      RegExp(r'^(?:artist|by|author)\s*[:\-]\s*(.+)$', caseSensitive: false);
  static final RegExp _keyColon =
      RegExp(r'^key\s*(?:of)?\s*[:\-]?\s*([A-G][#b]?m?)\s*$',
          caseSensitive: false);
  static final RegExp _tempoColon =
      RegExp(r'^(?:tempo|bpm)\s*[:\-=]?\s*(\d{2,3})\s*$',
          caseSensitive: false);
  static final RegExp _capoColon =
      RegExp(r'^capo\s*[:\-]?\s*(\d{1,2})\s*$', caseSensitive: false);

  /// Common section headers that often appear on their own line.
  static final RegExp _sectionHeader = RegExp(
    r'^(intro|verse|pre[\s-]?chorus|chorus|bridge|tag|outro|interlude|ending|refrain|instrumental|solo|turnaround)'
    r'(?:\s*\d+)?\s*[:\-]?\s*$',
    caseSensitive: false,
  );

  static bool _looksLikeChord(String token) =>
      token.isNotEmpty && _chordToken.hasMatch(token);

  /// A line is a "chord line" when it's mostly chord tokens, has ≥1 chord,
  /// and is short (chord lines are typically sparse horizontally).
  static bool isChordLine(String line) {
    final trimmed = line.trim();
    if (trimmed.isEmpty) return false;
    final tokens = trimmed.split(RegExp(r'\s+'));
    if (tokens.isEmpty) return false;
    final chords = tokens.where(_looksLikeChord).length;
    // require ≥1 chord, ≥70% chord-ness, and no long "words" that scream lyric
    final hasLongWord = tokens.any((t) => t.length > 8 && !_looksLikeChord(t));
    return chords >= 1 && chords / tokens.length >= 0.7 && !hasLongWord;
  }

  /// Merge a chord line above a lyric line into ChordPro inline form.
  /// Uses column positions so chord placement survives the transform.
  static String mergeChordOverLyric(String chordLine, String lyricLine) {
    final chords = <({int col, String chord})>[];
    final pattern = RegExp(r'\S+');
    for (final match in pattern.allMatches(chordLine)) {
      final token = match.group(0)!;
      if (_looksLikeChord(token)) {
        chords.add((col: match.start, chord: token));
      }
    }
    if (chords.isEmpty) return lyricLine;

    // Pad lyric line so all chord columns are reachable.
    final maxCol = chords.last.col;
    final padded = lyricLine.padRight(maxCol + 1);

    // Insert from the end so earlier columns stay aligned.
    final buf = StringBuffer();
    int cursor = 0;
    for (final c in chords) {
      final col = c.col.clamp(0, padded.length);
      buf.write(padded.substring(cursor, col));
      buf.write('[${c.chord}]');
      cursor = col;
    }
    buf.write(padded.substring(cursor));
    return buf.toString().trimRight();
  }

  /// Convert a chord-only instrumental line to inline form: `G  D  Em  C` →
  /// `[G] [D] [Em] [C]`.
  static String chordOnlyLine(String line) {
    final tokens = line.trim().split(RegExp(r'\s+'));
    return tokens.map((t) => _looksLikeChord(t) ? '[$t]' : t).join(' ');
  }

  /// Top-level conversion.
  static String textToChordPro(String raw) {
    final lines = raw.replaceAll('\r\n', '\n').split('\n');

    // Step 1 — infer metadata from leading non-chord, non-section lines.
    String? title, artist, key, tempo, capo;
    int bodyStart = 0;
    for (int i = 0; i < lines.length && i < 20; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) {
        bodyStart = i + 1;
        continue;
      }

      final mTitle = _titleColon.firstMatch(line);
      if (mTitle != null) {
        title ??= mTitle.group(1)!.trim();
        bodyStart = i + 1;
        continue;
      }
      final mArtist = _artistColon.firstMatch(line);
      if (mArtist != null) {
        artist ??= mArtist.group(1)!.trim();
        bodyStart = i + 1;
        continue;
      }
      final mKey = _keyColon.firstMatch(line);
      if (mKey != null) {
        key ??= mKey.group(1)!.trim();
        bodyStart = i + 1;
        continue;
      }
      final mTempo = _tempoColon.firstMatch(line);
      if (mTempo != null) {
        tempo ??= mTempo.group(1)!.trim();
        bodyStart = i + 1;
        continue;
      }
      final mCapo = _capoColon.firstMatch(line);
      if (mCapo != null) {
        capo ??= mCapo.group(1)!.trim();
        bodyStart = i + 1;
        continue;
      }

      // First plausible line that isn't a chord row and isn't a section header
      // is probably the title (if we haven't grabbed one yet).
      if (title == null &&
          !isChordLine(line) &&
          !_sectionHeader.hasMatch(line) &&
          line.length < 80) {
        title = line;
        bodyStart = i + 1;
        continue;
      }
      break;
    }

    // Step 2 — walk body lines, merging chord-over-lyric pairs.
    final out = <String>[];
    String? openSection;

    int i = bodyStart;
    while (i < lines.length) {
      final line = lines[i];
      final trimmed = line.trim();

      if (trimmed.isEmpty) {
        out.add('');
        i++;
        continue;
      }

      // Section header?
      final sec = _sectionHeader.firstMatch(trimmed);
      if (sec != null) {
        if (openSection != null) {
          out.add('{end_of_$openSection}');
        }
        final kind = _sectionKind(sec.group(1)!);
        out.add('{start_of_$kind}');
        openSection = kind;
        i++;
        continue;
      }

      if (isChordLine(line)) {
        // Only merge if the very next line (no blank in between) is a lyric.
        // A blank gap means this chord row stands alone (instrumental).
        if (i + 1 < lines.length &&
            lines[i + 1].trim().isNotEmpty &&
            !isChordLine(lines[i + 1])) {
          out.add(mergeChordOverLyric(line, lines[i + 1]));
          i += 2;
          continue;
        }
        // Chord-only line (instrumental break)
        out.add(chordOnlyLine(line));
        i++;
        continue;
      }

      // Plain lyric line.
      out.add(trimmed);
      i++;
    }

    if (openSection != null) {
      out.add('{end_of_$openSection}');
    }

    // Step 3 — assemble final ChordPro.
    final buf = StringBuffer();
    if (title != null) buf.writeln('{title: $title}');
    if (artist != null) buf.writeln('{artist: $artist}');
    if (key != null) buf.writeln('{key: $key}');
    if (tempo != null) buf.writeln('{tempo: $tempo}');
    if (capo != null) buf.writeln('{capo: $capo}');
    if (buf.isNotEmpty) buf.writeln();
    for (final l in out) {
      buf.writeln(l);
    }
    return buf.toString().trim();
  }

  static String _sectionKind(String header) {
    final h = header.toLowerCase().replaceAll(RegExp(r'[\s-]'), '');
    if (h.startsWith('pre')) return 'verse'; // pre-chorus → treat as verse
    if (h.startsWith('chorus') || h == 'refrain') return 'chorus';
    if (h.startsWith('bridge')) return 'bridge';
    if (h.contains('solo') || h.contains('instrumental') ||
        h.contains('interlude') || h.contains('intro') || h.contains('outro') ||
        h.contains('ending') || h.contains('turnaround') || h.contains('tag')) {
      return 'verse'; // ChordPro parser only knows verse/chorus/bridge/tab
    }
    return 'verse';
  }
}
