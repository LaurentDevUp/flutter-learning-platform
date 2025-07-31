import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Create a new record
  Future<Map<String, dynamic>> createRecord({
    required String table,
    required Map<String, dynamic> data,
  }) async {
    final response = await _supabase.from(table).insert(data).select().single();
    return response;
  }

  // Read all records from a table
  Future<List<Map<String, dynamic>>> readRecords(String table) async {
    final response = await _supabase.from(table).select();
    return response;
  }

  // Read a single record
  Future<Map<String, dynamic>?> readRecord({
    required String table,
    required String id,
  }) async {
    final response = await _supabase
        .from(table)
        .select()
        .eq('id', id)
        .maybeSingle();
    return response;
  }

  // Update a record
  Future<Map<String, dynamic>> updateRecord({
    required String table,
    required String id,
    required Map<String, dynamic> data,
  }) async {
    final response = await _supabase
        .from(table)
        .update(data)
        .eq('id', id)
        .select()
        .single();
    return response;
  }

  // Delete a record
  Future<void> deleteRecord({
    required String table,
    required String id,
  }) async {
    await _supabase.from(table).delete().eq('id', id);
  }
}
