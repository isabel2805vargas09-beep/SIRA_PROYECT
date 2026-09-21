import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String url = 'https://kdzfzxqkwkdyugccdggn.supabase.co';
  static const String publishableKey =
      'sb_publishable_5V42zkxvcGh3pFn0AfoTtw_9XcdVXGt';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: url,
      anonKey: publishableKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
