import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config/supabase_config.dart';
import 'data/hive_store.dart';
import 'providers/theme_provider.dart';
import 'ui/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveStore.init();

  if (SupabaseConfig.isConfigured) {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
  }

  runApp(const ProviderScope(child: OpenPraiseApp()));
}

class OpenPraiseApp extends ConsumerWidget {
  const OpenPraiseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    return MaterialApp(
      title: 'Open Praise',
      debugShowCheckedModeBanner: false,
      theme: theme.toThemeData(),
      home: const HomeScreen(),
    );
  }
}
