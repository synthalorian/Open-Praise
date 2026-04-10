import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config/supabase_config.dart';
import 'data/hive_store.dart';
import 'ui/home/home_screen.dart';
import 'ui/theme.dart';

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

class OpenPraiseApp extends StatelessWidget {
  const OpenPraiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Open Praise',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: NeonTheme.bg,
        primaryColor: NeonTheme.neonGreen,
        colorScheme: ColorScheme.dark(
          primary: NeonTheme.neonGreen,
          secondary: NeonTheme.neonPink,
          surface: NeonTheme.surface,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(
              color: NeonTheme.neonGreen, fontFamily: 'monospace'),
          bodyMedium: TextStyle(color: Colors.white70),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: NeonTheme.bg,
          elevation: 0,
          iconTheme: IconThemeData(color: NeonTheme.neonGreen),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
