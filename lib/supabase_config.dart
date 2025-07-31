import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/app_config.dart';

class SupabaseConfig {
  static String get supabaseUrl => AppConfig.supabaseUrl;
  static String get supabaseAnonKey => AppConfig.supabaseAnonKey;

  static Future<void> initialize() async {
    if (!AppConfig.isConfigured) {
      throw Exception(
        'Supabase configuration missing. Please set SUPABASE_URL and SUPABASE_ANON_KEY environment variables.',
      );
    }
    
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
