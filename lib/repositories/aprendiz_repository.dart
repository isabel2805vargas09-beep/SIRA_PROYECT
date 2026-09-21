import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/aprendiz.dart';

class AprendizRepository {
  final SupabaseClient _client = SupabaseConfig.client;

  Future<void> crear(Aprendiz aprendiz) async {
    await _client.from('aprendiz').insert(aprendiz.toMap());
  }
}
