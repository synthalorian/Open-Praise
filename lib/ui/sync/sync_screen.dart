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
    final theme = AppTheme.of(context);

    return Scaffold(
      backgroundColor: theme.bg,
      appBar: theme.appBar('SYNC BRIDGE'),
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
    final theme = AppTheme.of(context);

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_tethering, size: 80, color: theme.tertiary),
          const SizedBox(height: 16),
          Text('SYNC BRIDGE', style: theme.heading.copyWith(fontSize: 20)),
          const SizedBox(height: 8),
          Text(
            'Leader controls the setlist.\nFollowers sync automatically.',
            textAlign: TextAlign.center,
            style: TextStyle(color: theme.muted, fontSize: 13),
          ),
          const SizedBox(height: 32),
          if (remoteAvailable) ...[
            Container(
              decoration: theme.neonBorder(theme.tertiary),
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
              style: TextStyle(color: theme.muted, fontSize: 11),
            ),
            const SizedBox(height: 32),
          ],
          SizedBox(
            width: 280,
            child: OutlinedButton.icon(
              onPressed: () => _startAsLeader(context),
              icon: Icon(Icons.star, color: theme.tertiary),
              label: Text(
                _remoteMode ? 'CREATE ROOM' : 'START AS LEADER',
                style: TextStyle(
                  color: theme.tertiary,
                  letterSpacing: 2,
                  fontFamily: theme.monoFont,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: theme.neonButton(theme.tertiary),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 280,
            child: OutlinedButton.icon(
              onPressed: () =>
                  _remoteMode ? _joinRemoteRoom(context) : _startAsFollower(),
              icon: Icon(Icons.people, color: theme.secondary),
              label: Text(
                _remoteMode ? 'JOIN ROOM' : 'JOIN AS FOLLOWER',
                style: TextStyle(
                  color: theme.secondary,
                  letterSpacing: 2,
                  fontFamily: theme.monoFont,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: theme.neonButton(theme.secondary),
            ),
          ),
        ],
      ),
    );
  }

  void _startAsLeader(BuildContext context) {
    final controller = TextEditingController(text: 'WORSHIP LEADER');
    final theme = AppTheme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.surface,
        title: Text(
          _remoteMode ? 'CREATE ROOM' : 'LEADER NAME',
          style: theme.heading.copyWith(fontSize: 16),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: theme.mono,
          decoration: InputDecoration(
            hintText: 'Your display name...',
            hintStyle: TextStyle(color: theme.muted),
            enabledBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: theme.tertiary.withValues(alpha: 0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: theme.tertiary),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('CANCEL', style: TextStyle(color: theme.muted)),
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
                widget.ref.read(syncProvider.notifier).startAsLeader(name);
              }
              Navigator.pop(ctx);
            },
            style: theme.neonButton(theme.tertiary),
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
    final theme = AppTheme.of(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.surface,
        title: Text('JOIN ROOM', style: theme.heading.copyWith(fontSize: 16)),
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
              style: theme.mono.copyWith(
                fontSize: 28,
                letterSpacing: 8,
                color: theme.tertiary,
              ),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: 'ROOM CODE',
                hintStyle: TextStyle(
                  color: theme.muted,
                  fontSize: 20,
                  letterSpacing: 4,
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: theme.tertiary.withValues(alpha: 0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: theme.tertiary),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              style: theme.mono,
              decoration: InputDecoration(
                hintText: 'Your name...',
                hintStyle: TextStyle(color: theme.muted),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: theme.secondary.withValues(alpha: 0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: theme.secondary),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('CANCEL', style: TextStyle(color: theme.muted)),
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
            style: theme.neonButton(theme.secondary),
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
    final theme = AppTheme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? theme.tertiary.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 16,
                color: isActive ? theme.tertiary : theme.muted),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isActive ? theme.tertiary : theme.muted,
                fontFamily: theme.monoFont,
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
    final theme = AppTheme.of(context);
    final isLeader = syncState.role == SyncRole.leader;
    final color = isLeader ? theme.tertiary : theme.secondary;

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
            style: theme.heading.copyWith(fontSize: 20, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            syncState.isRemote ? 'REMOTE' : 'LOCAL',
            style: TextStyle(
              color: theme.muted,
              fontFamily: theme.monoFont,
              letterSpacing: 3,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: theme.neonBorder(color),
            child: Text(
              syncState.isConnected ? 'CONNECTED' : 'SEARCHING...',
              style: theme.mono.copyWith(color: color),
            ),
          ),
          if (syncState.roomCode != null) ...[
            const SizedBox(height: 24),
            Text('ROOM CODE',
                style: TextStyle(
                    color: theme.muted, letterSpacing: 3, fontSize: 11)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                Clipboard.setData(
                    ClipboardData(text: syncState.roomCode!));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Room code copied!'),
                    backgroundColor: theme.surface,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: theme.neonBorder(theme.primary),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      syncState.roomCode!,
                      style: theme.mono.copyWith(
                        fontSize: 32,
                        letterSpacing: 8,
                        color: theme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.copy, size: 20, color: theme.primary),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text('TAP TO COPY',
                style: TextStyle(
                    color: theme.muted, letterSpacing: 2, fontSize: 10)),
          ],
          if (syncState.leaderName != null && !isLeader) ...[
            const SizedBox(height: 16),
            Text('Leader: ${syncState.leaderName}',
                style: TextStyle(color: theme.muted)),
          ],
          if (isLeader && syncState.isRemote) ...[
            const SizedBox(height: 16),
            Text(
              '${syncState.followerCount} follower${syncState.followerCount == 1 ? "" : "s"} connected',
              style: TextStyle(color: theme.muted, fontSize: 13),
            ),
          ],
          const SizedBox(height: 48),
          OutlinedButton.icon(
            onPressed: () {
              ref.read(syncProvider.notifier).disconnect();
            },
            icon: const Icon(Icons.close, color: Colors.redAccent),
            label: Text('DISCONNECT',
                style: TextStyle(
                    color: Colors.redAccent,
                    letterSpacing: 2,
                    fontFamily: theme.monoFont)),
            style: theme.neonButton(Colors.redAccent),
          ),
        ],
      ),
    );
  }
}
