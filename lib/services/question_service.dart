import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/question.dart';

class QuestionService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get all questions for a fiche
  Future<List<Question>> getQuestions(String ficheId) async {
    final response = await _supabase
        .from('questions')
        .select()
        .eq('fiche_id', ficheId)
        .order('created_at', ascending: true);

    return response.map((json) => Question.fromJson(json)).toList();
  }

  // Get a single question
  Future<Question?> getQuestion(String id) async {
    final response = await _supabase
        .from('questions')
        .select()
        .eq('id', id)
        .maybeSingle();

    return response != null ? Question.fromJson(response) : null;
  }

  // Create a new question
  Future<Question> createQuestion({
    required String ficheId,
    required String questionText,
    required QuestionType questionType,
    List<String>? options,
    required String correctAnswer,
    String? explanation,
  }) async {
    final response = await _supabase.from('questions').insert({
      'fiche_id': ficheId,
      'question_text': questionText,
      'question_type': questionType.toString().split('.').last,
      'options': options,
      'correct_answer': correctAnswer,
      'explanation': explanation,
    }).select().single();

    return Question.fromJson(response);
  }

  // Update a question
  Future<Question> updateQuestion({
    required String id,
    String? questionText,
    QuestionType? questionType,
    List<String>? options,
    String? correctAnswer,
    String? explanation,
  }) async {
    final data = <String, dynamic>{};
    if (questionText != null) data['question_text'] = questionText;
    if (questionType != null) data['question_type'] = questionType.toString().split('.').last;
    if (options != null) data['options'] = options;
    if (correctAnswer != null) data['correct_answer'] = correctAnswer;
    if (explanation != null) data['explanation'] = explanation;

    final response = await _supabase
        .from('questions')
        .update(data)
        .eq('id', id)
        .select()
        .single();

    return Question.fromJson(response);
  }

  // Delete a question
  Future<void> deleteQuestion(String id) async {
    await _supabase.from('questions').delete().eq('id', id);
  }

  // Subscribe to real-time changes
  Stream<List<Question>> subscribeToQuestions(String ficheId) {
    return _supabase
        .from('questions')
        .stream(primaryKey: ['id'])
        .eq('fiche_id', ficheId)
        .order('created_at', ascending: true)
        .map((data) => data.map((json) => Question.fromJson(json)).toList());
  }
}
