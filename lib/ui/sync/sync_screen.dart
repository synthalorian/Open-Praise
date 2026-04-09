import 'package:flutter/material.dart';
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

class _RoleSelector extends StatelessWidget {
  final WidgetRef ref;

  const _RoleSelector({required this.ref});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.wifi_tethering, size: 80, color: NeonTheme.neonCyan),
        const SizedBox(height: 16),
        Text('SELECT ROLE',
            style: NeonTheme.heading.copyWith(fontSize: 20)),
        const SizedBox(height: 8),
        const Text(
          'Leader controls the setlist.\nFollowers sync automatically.',
          textAlign: TextAlign.center,
          style: TextStyle(color: NeonTheme.muted, fontSize: 13),
        ),
        const SizedBox(height: 48),

        // Leader button
        SizedBox(
          width: 280,
          child: OutlinedButton.icon(
            onPressed: () => _startAsLeader(context),
            icon: const Icon(Icons.star, color: NeonTheme.neonCyan),
            label: const Text('START AS LEADER',
                style: TextStyle(
                    color: NeonTheme.neonCyan,
                    letterSpacing: 2,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold)),
            style: NeonTheme.neonButton(NeonTheme.neonCyan),
          ),
        ),
        const SizedBox(height: 16),

        // Follower button
        SizedBox(
          width: 280,
          child: OutlinedButton.icon(
            onPressed: () {
              ref.read(syncProvider.notifier).startAsFollower();
            },
            icon: const Icon(Icons.people, color: NeonTheme.neonPink),
            label: const Text('JOIN AS FOLLOWER',
                style: TextStyle(
                    color: NeonTheme.neonPink,
                    letterSpacing: 2,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold)),
            style: NeonTheme.neonButton(NeonTheme.neonPink),
          ),
        ),
      ],
    );
  }

  void _startAsLeader(BuildContext context) {
    final controller = TextEditingController(text: 'WORSHIP LEADER');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: NeonTheme.surface,
        title: Text('LEADER NAME',
            style: NeonTheme.heading.copyWith(fontSize: 16)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: NeonTheme.mono,
          decoration: InputDecoration(
            hintText: 'Your display name...',
            hintStyle: const TextStyle(color: NeonTheme.muted),
            enabledBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: NeonTheme.neonCyan.withValues(alpha:0.3)),
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
              ref
                  .read(syncProvider.notifier)
                  .startAsLeader(controller.text.trim());
              Navigator.pop(ctx);
            },
            style: NeonTheme.neonButton(NeonTheme.neonCyan),
            child: const Text('GO LIVE'),
          ),
        ],
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

    return Column(
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
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: NeonTheme.neonBorder(color),
          child: Text(
            syncState.isConnected ? 'CONNECTED' : 'SEARCHING...',
            style: NeonTheme.mono.copyWith(color: color),
          ),
        ),
        if (syncState.leaderName != null) ...[
          const SizedBox(height: 16),
          Text('Leader: ${syncState.leaderName}',
              style: const TextStyle(color: NeonTheme.muted)),
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
    );
  }
}
