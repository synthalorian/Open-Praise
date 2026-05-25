import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config/supabase_config.dart';
import 'data/hive_store.dart';
import 'providers/theme_provider.dart';
import 'ui/home/home_screen.dart';

void main() async {
  // ── Global error handlers ──────────────────────────────
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    // In production, send to crash reporting backend.
    // Sentry / Firebase Crashlytics integration point.
    debugPrint('🚨 FlutterError: ${details.exception}');
    debugPrint('   Stack: ${details.stack}');
  };

  // Custom error widget for uncaught build errors
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return const Material(
      color: Color(0xFF0B0420),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline,
                  color: Color(0xFFFF2EC8), size: 64),
              SizedBox(height: 16),
              _ErrorTitle(),
              SizedBox(height: 12),
              _ErrorMessage(),
            ],
          ),
        ),
      ),
    );
  };

  // ── App initialization ─────────────────────────────────
  WidgetsFlutterBinding.ensureInitialized();
  await HiveStore.init();

  if (SupabaseConfig.isConfigured) {
    try {
      await Supabase.initialize(
        url: SupabaseConfig.url,
        anonKey: SupabaseConfig.anonKey,
      );
    } catch (e) {
      // If Supabase fails to initialize, remote sync won't be available
      // but the app should still work for local-only usage.
      debugPrint('⚠️ Supabase init skipped: $e');
    }
  }

  runApp(
    // ProviderScope at the root so Riverpod state survives hot reload.
    const ProviderScope(
      child: OpenPraiseApp(),
    ),
  );
}

/// Title shown in the error widget.
class _ErrorTitle extends StatelessWidget {
  const _ErrorTitle();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'OPEN PRAISE',
      style: TextStyle(
        fontFamily: 'monospace',
        color: Color(0xFFB26CFF),
        fontWeight: FontWeight.bold,
        letterSpacing: 2.0,
        fontSize: 20,
      ),
    );
  }
}

/// Message shown in the error widget.
class _ErrorMessage extends StatelessWidget {
  const _ErrorMessage();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Something went wrong.\nPlease restart the app.',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Color(0xFFEDE0FF).withValues(alpha: 0.8),
        fontSize: 14,
      ),
    );
  }
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
