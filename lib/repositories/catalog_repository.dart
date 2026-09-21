import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/ciudad.dart';
import '../models/departamento.dart';

class CatalogRepository {
  final SupabaseClient _client = SupabaseConfig.client;

  Future<List<Departamento>> getDepartamentos() async {
    final rows = await _client
        .from('departamento')
        .select('"código", nombre')
        .order('nombre');

    return (rows as List)
        .map((row) => Departamento.fromMap(Map<String, dynamic>.from(row)))
        .where((d) => d.codigo.isNotEmpty && d.nombre.isNotEmpty)
        .toList();
  }

  Future<List<Ciudad>> getCiudades(String departamento) async {
    final rows = await _client
        .from('ciudad')
        .select('departamento, "código", nombre')
        .eq('departamento', departamento)
        .order('nombre');

    return (rows as List)
        .map((row) => Ciudad.fromMap(Map<String, dynamic>.from(row)))
        .where((c) => c.codigo.isNotEmpty && c.nombre.isNotEmpty)
        .toList();
  }
}
