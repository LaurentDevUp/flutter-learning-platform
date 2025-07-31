import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/fiche.dart';

class FicheService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get all fiches for current user
  Future<List<Fiche>> getFiches() async {
    final response = await _supabase
        .from('fiches')
        .select()
        .order('updated_at', ascending: false);
    
    return response.map((json) => Fiche.fromJson(json)).toList();
  }

  // Get a single fiche
  Future<Fiche?> getFiche(String id) async {
    final response = await _supabase
        .from('fiches')
        .select()
        .eq('id', id)
        .maybeSingle();
    
    return response != null ? Fiche.fromJson(response) : null;
  }

  // Create a new fiche
  Future<Fiche> createFiche({
    required String title,
    required String content,
    String? summary,
    List<String> keywords = const [],
  }) async {
    final response = await _supabase.from('fiches').insert({
      'title': title,
      'content': content,
      'summary': summary,
      'keywords': keywords,
      'user_id': _supabase.auth.currentUser!.id,
    }).select().single();

    return Fiche.fromJson(response);
  }

  // Update a fiche
  Future<Fiche> updateFiche({
    required String id,
    String? title,
    String? content,
    String? summary,
    List<String>? keywords,
  }) async {
    final data = <String, dynamic>{};
    if (title != null) data['title'] = title;
    if (content != null) data['content'] = content;
    if (summary != null) data['summary'] = summary;
    if (keywords != null) data['keywords'] = keywords;
    data['updated_at'] = DateTime.now().toIso8601String();

    final response = await _supabase
        .from('fiches')
        .update(data)
        .eq('id', id)
        .select()
        .single();

    return Fiche.fromJson(response);
  }

  // Delete a fiche
  Future<void> deleteFiche(String id) async {
    await _supabase.from('fiches').delete().eq('id', id);
  }

  // Search fiches by keywords or title
  Future<List<Fiche>> searchFiches(String query) async {
    final response = await _supabase
        .from('fiches')
        .select()
        .eq('user_id', _supabase.auth.currentUser!.id)
        .or('title.ilike.%$query%,keywords.cs.{"$query"}')
        .order('updated_at', ascending: false);

    return response.map((json) => Fiche.fromJson(json)).toList();
  }

  // Subscribe to real-time changes
  Stream<List<Fiche>> subscribeToFiches() {
    return _supabase
        .from('fiches')
        .stream(primaryKey: ['id'])
        .eq('user_id', _supabase.auth.currentUser!.id)
        .order('updated_at', ascending: false)
        .map((data) => data.map((json) => Fiche.fromJson(json)).toList());
  }
}
