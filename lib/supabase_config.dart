import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://fnoncwektdnxxouyvatn.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZub25jd2VrdGRueHhvdXl2YXRuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM5Njc5OTAsImV4cCI6MjA2OTU0Mzk5MH0.gcWs02d_-jUd13N3JCS5Twagy9s_YrM6OhejwcHHqVY';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
