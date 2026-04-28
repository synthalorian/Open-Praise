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
    final theme = AppTheme.of(context);

    return Scaffold(
      backgroundColor: theme.bg,
      appBar: theme.appBar('SETLISTS', actions: [
        IconButton(
          icon: Icon(Icons.add, color: theme.secondary),
          tooltip: 'New Setlist',
          onPressed: () => _showCreateDialog(context, ref),
        ),
      ]),
      body: setlists.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.queue_music, size: 64, color: theme.muted),
                  const SizedBox(height: 16),
                  Text('NO SETLISTS YET',
                      style: TextStyle(
                          color: theme.muted,
                          letterSpacing: 2,
                          fontSize: 14)),
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    onPressed: () => _showCreateDialog(context, ref),
                    icon: const Icon(Icons.add),
                    label: const Text('CREATE SETLIST'),
                    style: theme.neonButton(theme.secondary),
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
    final theme = AppTheme.of(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.surface,
        title:
            Text('NEW SETLIST', style: theme.heading.copyWith(fontSize: 16)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: theme.mono,
          decoration: InputDecoration(
            hintText: 'Setlist name...',
            hintStyle: TextStyle(color: theme.muted),
            enabledBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: theme.primary.withValues(alpha: 0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: theme.primary),
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
              if (controller.text.trim().isNotEmpty) {
                ref
                    .read(setlistProvider.notifier)
                    .createSetlist(controller.text.trim());
                Navigator.pop(ctx);
              }
            },
            style: theme.neonButton(theme.secondary),
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
    final theme = AppTheme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: theme.neonBorder(theme.secondary),
      child: ListTile(
        leading: Icon(Icons.queue_music, color: theme.secondary),
        title: Text(setlist.name,
            style: theme.mono.copyWith(
                fontWeight: FontWeight.bold, color: theme.secondary)),
        subtitle: Text(
          '${setlist.songIds.length} song${setlist.songIds.length == 1 ? "" : "s"}',
          style: TextStyle(color: theme.muted, fontSize: 12),
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
