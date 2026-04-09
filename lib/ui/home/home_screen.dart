import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/sync_provider.dart';
import '../theme.dart';
import '../song_library/song_library_screen.dart';
import '../setlist/setlist_list_screen.dart';
import '../sync/sync_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncProvider);

    return Scaffold(
      backgroundColor: NeonTheme.bg,
      appBar: NeonTheme.appBar('OPEN PRAISE // S6.5'),
      body: Stack(
        children: [
          // Background grid
          Positioned.fill(child: CustomPaint(painter: _GridPainter())),

          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  const Icon(Icons.music_note_rounded,
                      size: 80, color: NeonTheme.neonGreen),
                  const SizedBox(height: 8),
                  Text('OPEN PRAISE',
                      style: NeonTheme.heading.copyWith(
                        fontSize: 28,
                        shadows: [
                          const Shadow(
                              color: NeonTheme.neonGreen, blurRadius: 12),
                        ],
                      )),
                  const SizedBox(height: 4),
                  const Text('S6.5 // STAGE READY',
                      style: TextStyle(
                          color: NeonTheme.muted,
                          letterSpacing: 3,
                          fontSize: 12)),
                  const SizedBox(height: 48),

                  // Main actions
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
                        ? NeonTheme.neonCyan
                        : NeonTheme.neonGreen,
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
  final Color color;

  const _MenuButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = NeonTheme.neonGreen,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: color),
        label: Text(label,
            style: TextStyle(
                color: color,
                letterSpacing: 2,
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold)),
        style: NeonTheme.neonButton(color),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = NeonTheme.neonGreen.withValues(alpha:0.04)
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
