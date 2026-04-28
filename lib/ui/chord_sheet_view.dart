import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../features/chord_engine/models.dart';
import 'theme.dart';

class ChordSheetView extends ConsumerWidget {
  final Song song;

  const ChordSheetView({
    super.key,
    required this.song,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: song.sections.length,
      itemBuilder: (context, index) {
        final section = song.sections[index];
        return _SectionWidget(section: section);
      },
    );
  }
}

class _SectionWidget extends StatelessWidget {
  final SongSection section;

  const _SectionWidget({required this.section});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: theme.sectionHeaderBorder),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              section.title.toUpperCase(),
              style: TextStyle(
                color: theme.sectionHeader,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                fontFamily: theme.monoFont,
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...section.lines.map((line) => _LineWidget(line: line)),
        ],
      ),
    );
  }
}

class _LineWidget extends StatelessWidget {
  final String line;

  const _LineWidget({required this.line});

  @override
  Widget build(BuildContext context) {
    final pairs = _parseChordPairs(line);
    if (pairs.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.start,
        children: pairs
            .map((p) => _ChordLyricPair(chord: p.chord, word: p.word))
            .toList(),
      ),
    );
  }

  /// Splits a ChordPro-inline line into per-word (chord?, word) pairs.
  /// `[G]Amazing [D]grace` → [(G, "Amazing"), (null, "grace")]
  /// Chord-only segments (instrumental) become (chord, "").
  /// A chord attaches to the first word of the segment that follows it; later
  /// words in the same segment carry no chord.
  static List<({String? chord, String word})> _parseChordPairs(String line) {
    final out = <({String? chord, String word})>[];
    final segment = RegExp(r'\[([^\]]+)\]([^\[]*)|([^\[]+)');
    for (final m in segment.allMatches(line)) {
      final chord = m.group(1);
      final lyric = (m.group(2) ?? m.group(3) ?? '');
      final words = lyric.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
      if (words.isEmpty) {
        if (chord != null) out.add((chord: chord, word: ''));
        continue;
      }
      for (var i = 0; i < words.length; i++) {
        out.add((chord: i == 0 ? chord : null, word: words[i]));
      }
    }
    return out;
  }
}

class _ChordLyricPair extends StatelessWidget {
  final String? chord;
  final String word;

  const _ChordLyricPair({required this.chord, required this.word});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 22,
            child: chord == null
                ? null
                : Text(
                    chord!,
                    style: TextStyle(
                      color: theme.chord,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      fontFamily: theme.monoFont,
                      height: 1.1,
                    ),
                  ),
          ),
          Text(
            word,
            style: TextStyle(
              color: theme.text,
              fontSize: 18,
              height: 1.2,
              fontFamily: theme.bodyFont,
            ),
          ),
        ],
      ),
    );
  }
}
