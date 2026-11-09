import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  /// Supabase Project URL (e.g., https://your-project.supabase.co)
  /// Replace with your actual project URL from your Supabase dashboard (Settings -> API)
  static const String supabaseUrl = 'https://your-project-id.supabase.co';

  /// Supabase Anon Public API Key (safe to use in Flutter client)
  /// Replace with your actual anon public key from your Supabase dashboard (Settings -> API)
  static const String supabaseAnonKey = 'your-anon-key-here';

  /// Supabase Edge Function name for Vision AI analysis
  static const String aiAnalysisFunctionName = 'analyze-toilet-image';

  /// Check whether the developer has configured actual Supabase credentials
  static bool get isConfigured {
    return supabaseUrl.isNotEmpty &&
        supabaseAnonKey.isNotEmpty &&
        !supabaseUrl.contains('your-project-id') &&
        !supabaseAnonKey.contains('your-anon-key');
  }

  /// Global Supabase client instance accessor
  static SupabaseClient get client => Supabase.instance.client;

  /// Initialize Supabase Flutter SDK
  static Future<void> initialize() async {
    if (isConfigured) {
      try {
        // ignore: deprecated_member_use
        await Supabase.initialize(
          url: supabaseUrl,
          // ignore: deprecated_member_use
          anonKey: supabaseAnonKey,
          debug: false,
        );
      } catch (e) {
        // Log initialization error; UI handles unconfigured/offline state gracefully
        // ignore: avoid_print
        print('Supabase initialization failed: $e');
      }
    }
  }
}
