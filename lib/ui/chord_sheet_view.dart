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
    final theme = AppTheme.of(context);
    final parts = line.split(RegExp(r'(?=\[)|(?<=\])'));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.end,
        children: parts.map((part) {
          if (part.startsWith('[') && part.endsWith(']')) {
            final chord = part.substring(1, part.length - 1);
            return Padding(
              padding: const EdgeInsets.only(right: 4.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    chord,
                    style: TextStyle(
                      color: theme.chord,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      fontFamily: theme.monoFont,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          } else {
            return Text(
              part,
              style: TextStyle(
                color: theme.text,
                fontSize: 18,
                height: 1.5,
                fontFamily: theme.bodyFont,
              ),
            );
          }
        }).toList(),
      ),
    );
  }
}
