import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/chord_engine/models.dart';
import '../../providers/app_providers.dart';
import '../theme.dart';
import 'setlist_detail_screen.dart';

class SetlistListScreen extends ConsumerWidget {
  const SetlistListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setlists = ref.watch(setlistProvider);

    return Scaffold(
      backgroundColor: NeonTheme.bg,
      appBar: NeonTheme.appBar('SETLISTS', actions: [
        IconButton(
          icon: const Icon(Icons.add, color: NeonTheme.neonPink),
          tooltip: 'New Setlist',
          onPressed: () => _showCreateDialog(context, ref),
        ),
      ]),
      body: setlists.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.queue_music, size: 64, color: NeonTheme.muted),
                  const SizedBox(height: 16),
                  const Text('NO SETLISTS YET',
                      style: TextStyle(
                          color: NeonTheme.muted,
                          letterSpacing: 2,
                          fontSize: 14)),
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    onPressed: () => _showCreateDialog(context, ref),
                    icon: const Icon(Icons.add),
                    label: const Text('CREATE SETLIST'),
                    style: NeonTheme.neonButton(NeonTheme.neonPink),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: setlists.length,
              itemBuilder: (context, index) {
                final setlist = setlists[index];
                return _SetlistTile(setlist: setlist);
              },
            ),
    );
  }

  void _showCreateDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: NeonTheme.surface,
        title: Text('NEW SETLIST', style: NeonTheme.heading.copyWith(fontSize: 16)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: NeonTheme.mono,
          decoration: InputDecoration(
            hintText: 'Setlist name...',
            hintStyle: const TextStyle(color: NeonTheme.muted),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: NeonTheme.neonGreen.withValues(alpha:0.3)),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: NeonTheme.neonGreen),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL', style: TextStyle(color: NeonTheme.muted)),
          ),
          OutlinedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                ref.read(setlistProvider.notifier).createSetlist(controller.text.trim());
                Navigator.pop(ctx);
              }
            },
            style: NeonTheme.neonButton(NeonTheme.neonPink),
            child: const Text('CREATE'),
          ),
        ],
      ),
    );
  }
}

class _SetlistTile extends ConsumerWidget {
  final Setlist setlist;

  const _SetlistTile({required this.setlist});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: NeonTheme.neonBorder(NeonTheme.neonPink),
      child: ListTile(
        leading: const Icon(Icons.queue_music, color: NeonTheme.neonPink),
        title: Text(setlist.name,
            style: NeonTheme.mono.copyWith(
                fontWeight: FontWeight.bold, color: NeonTheme.neonPink)),
        subtitle: Text(
          '${setlist.songIds.length} song${setlist.songIds.length == 1 ? "" : "s"}',
          style: const TextStyle(color: NeonTheme.muted, fontSize: 12),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          onPressed: () {
            ref.read(setlistProvider.notifier).deleteSetlist(setlist.id);
          },
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SetlistDetailScreen(setlistId: setlist.id),
            ),
          );
        },
      ),
    );
  }
}
