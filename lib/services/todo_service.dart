import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/todo.dart';

class TodoService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get all todos for the current user
  Future<List<Todo>> getTodos() async {
    final response = await _supabase
        .from('todos')
        .select()
        .order('created_at', ascending: false);
    
    return response.map((json) => Todo.fromJson(json)).toList();
  }

  // Create a new todo
  Future<Todo> createTodo({
    required String title,
    String? description,
  }) async {
    final response = await _supabase.from('todos').insert({
      'title': title,
      'description': description,
      'user_id': _supabase.auth.currentUser!.id,
    }).select().single();

    return Todo.fromJson(response);
  }

  // Update a todo
  Future<Todo> updateTodo({
    required String id,
    String? title,
    String? description,
    bool? completed,
  }) async {
    final data = <String, dynamic>{};
    if (title != null) data['title'] = title;
    if (description != null) data['description'] = description;
    if (completed != null) data['completed'] = completed;
    data['updated_at'] = DateTime.now().toIso8601String();

    final response = await _supabase
        .from('todos')
        .update(data)
        .eq('id', id)
        .select()
        .single();

    return Todo.fromJson(response);
  }

  // Delete a todo
  Future<void> deleteTodo(String id) async {
    await _supabase.from('todos').delete().eq('id', id);
  }

  // Subscribe to real-time changes
  Stream<List<Todo>> subscribeToTodos() {
    return _supabase
        .from('todos')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) => data.map((json) => Todo.fromJson(json)).toList());
  }
}
