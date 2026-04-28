import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/sync_provider.dart';
import '../theme.dart';
import '../settings/settings_screen.dart';
import '../song_library/song_library_screen.dart';
import '../setlist/setlist_list_screen.dart';
import '../sync/sync_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncProvider);
    final theme = AppTheme.of(context);

    return Scaffold(
      backgroundColor: theme.bg,
      appBar: theme.appBar('OPEN PRAISE // S6.5', actions: [
        IconButton(
          icon: Icon(Icons.settings, color: theme.primary),
          tooltip: 'Settings',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          ),
        ),
      ]),
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _GridPainter(theme))),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.music_note_rounded, size: 80, color: theme.primary),
                  const SizedBox(height: 8),
                  Text('OPEN PRAISE',
                      style: theme.heading.copyWith(
                        fontSize: 28,
                        shadows: [
                          Shadow(
                              color: theme.primary
                                  .withValues(alpha: theme.glowStrength),
                              blurRadius: 12),
                        ],
                      )),
                  const SizedBox(height: 4),
                  Text('S6.5 // STAGE READY',
                      style: TextStyle(
                          color: theme.muted,
                          letterSpacing: 3,
                          fontSize: 12)),
                  const SizedBox(height: 48),
                  _MenuButton(
                    icon: Icons.library_music,
                    label: 'SONG LIBRARY',
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const SongLibraryScreen())),
                  ),
                  const SizedBox(height: 16),
                  _MenuButton(
                    icon: Icons.queue_music,
                    label: 'SETLISTS',
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const SetlistListScreen())),
                  ),
                  const SizedBox(height: 16),
                  _MenuButton(
                    icon: Icons.wifi_tethering,
                    label: syncState.isConnected
                        ? 'SYNC // ${syncState.role.name.toUpperCase()}'
                        : 'SYNC BRIDGE',
                    color: syncState.isConnected
                        ? theme.tertiary
                        : theme.primary,
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const SyncScreen())),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _MenuButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final c = color ?? theme.primary;
    return SizedBox(
      width: 300,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: c),
        label: Text(label,
            style: TextStyle(
                color: c,
                letterSpacing: 2,
                fontFamily: theme.monoFont,
                fontWeight: FontWeight.bold)),
        style: theme.neonButton(c),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  final AppTheme theme;
  _GridPainter(this.theme);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = theme.primary.withValues(alpha: 0.04 * theme.glowStrength)
      ..strokeWidth = 1.0;

    const spacing = 40.0;
    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) =>
      oldDelegate.theme.id != theme.id;
}
