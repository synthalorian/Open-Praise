/// Supabase configuration for remote sync.
///
/// To set up:
/// 1. Create a free project at https://supabase.com
/// 2. Go to Project Settings > API
/// 3. Copy the Project URL and anon/public key
/// 4. Paste them below
class SupabaseConfig {
  static const String url = 'https://YOUR_PROJECT.supabase.co';
  static const String anonKey = 'YOUR_ANON_KEY';

  /// Whether remote sync is available (keys are configured)
  static bool get isConfigured =>
      !url.contains('YOUR_PROJECT') && !anonKey.contains('YOUR_ANON_KEY');
}
