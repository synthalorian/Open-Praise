import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/sync_provider.dart';
import '../theme.dart';

class SyncScreen extends ConsumerWidget {
  const SyncScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncProvider);

    return Scaffold(
      backgroundColor: NeonTheme.bg,
      appBar: NeonTheme.appBar('SYNC BRIDGE'),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: syncState.role == SyncRole.none
              ? _RoleSelector(ref: ref)
              : _ConnectionStatus(syncState: syncState, ref: ref),
        ),
      ),
    );
  }
}

class _RoleSelector extends StatefulWidget {
  final WidgetRef ref;

  const _RoleSelector({required this.ref});

  @override
  State<_RoleSelector> createState() => _RoleSelectorState();
}

class _RoleSelectorState extends State<_RoleSelector> {
  bool _remoteMode = false;

  @override
  Widget build(BuildContext context) {
    final remoteAvailable =
        widget.ref.read(syncProvider.notifier).remoteAvailable;

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_tethering, size: 80, color: NeonTheme.neonCyan),
          const SizedBox(height: 16),
          Text('SYNC BRIDGE', style: NeonTheme.heading.copyWith(fontSize: 20)),
          const SizedBox(height: 8),
          const Text(
            'Leader controls the setlist.\nFollowers sync automatically.',
            textAlign: TextAlign.center,
            style: TextStyle(color: NeonTheme.muted, fontSize: 13),
          ),
          const SizedBox(height: 32),

          // Local / Remote toggle
          if (remoteAvailable) ...[
            Container(
              decoration: NeonTheme.neonBorder(NeonTheme.neonCyan),
              padding: const EdgeInsets.all(4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ModeTab(
                    label: 'LOCAL',
                    icon: Icons.wifi,
                    isActive: !_remoteMode,
                    onTap: () => setState(() => _remoteMode = false),
                  ),
                  _ModeTab(
                    label: 'REMOTE',
                    icon: Icons.public,
                    isActive: _remoteMode,
                    onTap: () => setState(() => _remoteMode = true),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _remoteMode
                  ? 'Sync over the internet via room code'
                  : 'Sync on the same Wi-Fi network',
              style: const TextStyle(color: NeonTheme.muted, fontSize: 11),
            ),
            const SizedBox(height: 32),
          ],

          // Leader button
          SizedBox(
            width: 280,
            child: OutlinedButton.icon(
              onPressed: () => _startAsLeader(context),
              icon: const Icon(Icons.star, color: NeonTheme.neonCyan),
              label: Text(
                _remoteMode ? 'CREATE ROOM' : 'START AS LEADER',
                style: const TextStyle(
                  color: NeonTheme.neonCyan,
                  letterSpacing: 2,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: NeonTheme.neonButton(NeonTheme.neonCyan),
            ),
          ),
          const SizedBox(height: 16),

          // Follower button
          SizedBox(
            width: 280,
            child: OutlinedButton.icon(
              onPressed: () =>
                  _remoteMode ? _joinRemoteRoom(context) : _startAsFollower(),
              icon: const Icon(Icons.people, color: NeonTheme.neonPink),
              label: Text(
                _remoteMode ? 'JOIN ROOM' : 'JOIN AS FOLLOWER',
                style: const TextStyle(
                  color: NeonTheme.neonPink,
                  letterSpacing: 2,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: NeonTheme.neonButton(NeonTheme.neonPink),
            ),
          ),
        ],
      ),
    );
  }

  void _startAsLeader(BuildContext context) {
    final controller = TextEditingController(text: 'WORSHIP LEADER');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: NeonTheme.surface,
        title: Text(
          _remoteMode ? 'CREATE ROOM' : 'LEADER NAME',
          style: NeonTheme.heading.copyWith(fontSize: 16),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: NeonTheme.mono,
          decoration: InputDecoration(
            hintText: 'Your display name...',
            hintStyle: const TextStyle(color: NeonTheme.muted),
            enabledBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: NeonTheme.neonCyan.withValues(alpha: 0.3)),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: NeonTheme.neonCyan),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                const Text('CANCEL', style: TextStyle(color: NeonTheme.muted)),
          ),
          OutlinedButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              if (_remoteMode) {
                widget.ref
                    .read(syncProvider.notifier)
                    .startRemoteLeader(name);
              } else {
                widget.ref
                    .read(syncProvider.notifier)
                    .startAsLeader(name);
              }
              Navigator.pop(ctx);
            },
            style: NeonTheme.neonButton(NeonTheme.neonCyan),
            child: Text(_remoteMode ? 'CREATE' : 'GO LIVE'),
          ),
        ],
      ),
    );
  }

  void _startAsFollower() {
    widget.ref.read(syncProvider.notifier).startAsFollower();
  }

  void _joinRemoteRoom(BuildContext context) {
    final codeController = TextEditingController();
    final nameController = TextEditingController(text: 'TEAM MEMBER');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: NeonTheme.surface,
        title:
            Text('JOIN ROOM', style: NeonTheme.heading.copyWith(fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: codeController,
              autofocus: true,
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                LengthLimitingTextInputFormatter(6),
              ],
              style: NeonTheme.mono.copyWith(
                fontSize: 28,
                letterSpacing: 8,
                color: NeonTheme.neonCyan,
              ),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: 'ROOM CODE',
                hintStyle: TextStyle(
                  color: NeonTheme.muted,
                  fontSize: 20,
                  letterSpacing: 4,
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: NeonTheme.neonCyan.withValues(alpha: 0.3)),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: NeonTheme.neonCyan),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              style: NeonTheme.mono,
              decoration: InputDecoration(
                hintText: 'Your name...',
                hintStyle: const TextStyle(color: NeonTheme.muted),
                enabledBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: NeonTheme.neonPink.withValues(alpha: 0.3)),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: NeonTheme.neonPink),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                const Text('CANCEL', style: TextStyle(color: NeonTheme.muted)),
          ),
          OutlinedButton(
            onPressed: () {
              final code = codeController.text.trim();
              final name = nameController.text.trim();
              if (code.length != 6 || name.isEmpty) return;
              widget.ref
                  .read(syncProvider.notifier)
                  .joinRemoteRoom(code, name);
              Navigator.pop(ctx);
            },
            style: NeonTheme.neonButton(NeonTheme.neonPink),
            child: const Text('JOIN'),
          ),
        ],
      ),
    );
  }
}

class _ModeTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _ModeTab({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? NeonTheme.neonCyan.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16,
                color: isActive ? NeonTheme.neonCyan : NeonTheme.muted),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isActive ? NeonTheme.neonCyan : NeonTheme.muted,
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConnectionStatus extends StatelessWidget {
  final SyncState syncState;
  final WidgetRef ref;

  const _ConnectionStatus({required this.syncState, required this.ref});

  @override
  Widget build(BuildContext context) {
    final isLeader = syncState.role == SyncRole.leader;
    final color = isLeader ? NeonTheme.neonCyan : NeonTheme.neonPink;

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            syncState.isConnected ? Icons.wifi_tethering : Icons.wifi_find,
            size: 80,
            color: color,
          ),
          const SizedBox(height: 16),
          Text(
            isLeader ? 'LEADER MODE' : 'FOLLOWER MODE',
            style: NeonTheme.heading.copyWith(fontSize: 20, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            syncState.isRemote ? 'REMOTE' : 'LOCAL',
            style: TextStyle(
              color: NeonTheme.muted,
              fontFamily: 'monospace',
              letterSpacing: 3,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: NeonTheme.neonBorder(color),
            child: Text(
              syncState.isConnected ? 'CONNECTED' : 'SEARCHING...',
              style: NeonTheme.mono.copyWith(color: color),
            ),
          ),

          // Room code display (remote mode)
          if (syncState.roomCode != null) ...[
            const SizedBox(height: 24),
            const Text('ROOM CODE',
                style: TextStyle(
                    color: NeonTheme.muted, letterSpacing: 3, fontSize: 11)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                Clipboard.setData(
                    ClipboardData(text: syncState.roomCode!));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Room code copied!'),
                    backgroundColor: NeonTheme.surface,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: NeonTheme.neonBorder(NeonTheme.neonGreen),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      syncState.roomCode!,
                      style: NeonTheme.mono.copyWith(
                        fontSize: 32,
                        letterSpacing: 8,
                        color: NeonTheme.neonGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.copy,
                        size: 20, color: NeonTheme.neonGreen),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text('TAP TO COPY',
                style: TextStyle(
                    color: NeonTheme.muted, letterSpacing: 2, fontSize: 10)),
          ],

          if (syncState.leaderName != null && !isLeader) ...[
            const SizedBox(height: 16),
            Text('Leader: ${syncState.leaderName}',
                style: const TextStyle(color: NeonTheme.muted)),
          ],

          if (isLeader && syncState.isRemote) ...[
            const SizedBox(height: 16),
            Text(
              '${syncState.followerCount} follower${syncState.followerCount == 1 ? "" : "s"} connected',
              style: const TextStyle(color: NeonTheme.muted, fontSize: 13),
            ),
          ],

          const SizedBox(height: 48),
          OutlinedButton.icon(
            onPressed: () {
              ref.read(syncProvider.notifier).disconnect();
            },
            icon: const Icon(Icons.close, color: Colors.redAccent),
            label: const Text('DISCONNECT',
                style: TextStyle(
                    color: Colors.redAccent,
                    letterSpacing: 2,
                    fontFamily: 'monospace')),
            style: NeonTheme.neonButton(Colors.redAccent),
          ),
        ],
      ),
    );
  }
}
