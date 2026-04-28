import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/theme_provider.dart';
import '../theme.dart';
import '../themes/theme_presets.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: active.bg,
      appBar: active.appBar('SETTINGS'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('THEME',
              style: active.heading.copyWith(fontSize: 14, letterSpacing: 3)),
          const SizedBox(height: 4),
          Text('Tap a card to switch looks.',
              style: TextStyle(color: active.muted, fontSize: 12)),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.35,
            children: AppThemes.all
                .map((preset) => _ThemeCard(
                      preset: preset,
                      isActive: preset.id == active.id,
                      onTap: () =>
                          ref.read(themeProvider.notifier).setTheme(preset.id),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  final AppTheme preset;
  final bool isActive;
  final VoidCallback onTap;

  const _ThemeCard({
    required this.preset,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: preset.bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive
                ? preset.primary
                : preset.primary.withValues(alpha: 0.3),
            width: isActive ? 2.5 : 1,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: preset.primary
                        .withValues(alpha: 0.4 * preset.glowStrength),
                    blurRadius: 12,
                  )
                ]
              : null,
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    preset.name.toUpperCase(),
                    style: TextStyle(
                      color: preset.primary,
                      fontFamily: preset.monoFont,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isActive)
                  Icon(Icons.check_circle,
                      color: preset.primary, size: 16),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              preset.tagline,
              style: TextStyle(
                color: preset.muted,
                fontFamily: preset.bodyFont,
                fontSize: 10,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Row(
              children: [
                _Swatch(color: preset.primary),
                const SizedBox(width: 6),
                _Swatch(color: preset.secondary),
                const SizedBox(width: 6),
                _Swatch(color: preset.tertiary),
              ],
            ),
            const SizedBox(height: 10),
            // Mini chord-sheet preview
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('[${_chordSample(preset)}]',
                    style: TextStyle(
                        color: preset.chord,
                        fontFamily: preset.monoFont,
                        fontSize: 11,
                        fontWeight: FontWeight.bold)),
                const SizedBox(width: 4),
                Text('grace',
                    style: TextStyle(
                        color: preset.text,
                        fontFamily: preset.bodyFont,
                        fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _chordSample(AppTheme preset) {
    // A different chord per theme just for flavor
    const sample = ['G', 'D', 'Em', 'C', 'Am', 'F', 'Bm', 'A'];
    return sample[preset.id.hashCode.abs() % sample.length];
  }
}

class _Swatch extends StatelessWidget {
  final Color color;
  const _Swatch({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
    );
  }
}
