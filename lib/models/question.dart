enum QuestionType {
  qcm,
  fillBlank,
  text,
  image,
  audio,
}

class Question {
  final String id;
  final String ficheId;
  final String questionText;
  final QuestionType questionType;
  final List<String>? options; // For QCM
  final String correctAnswer;
  final String? explanation;
  final DateTime createdAt;

  Question({
    required this.id,
    required this.ficheId,
    required this.questionText,
    required this.questionType,
    this.options,
    required this.correctAnswer,
    this.explanation,
    required this.createdAt,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      ficheId: json['fiche_id'],
      questionText: json['question_text'],
      questionType: QuestionType.values.firstWhere(
        (e) => e.toString().split('.').last == json['question_type'],
      ),
      options: json['options'] != null 
          ? List<String>.from(json['options']) 
          : null,
      correctAnswer: json['correct_answer'],
      explanation: json['explanation'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fiche_id': ficheId,
      'question_text': questionText,
      'question_type': questionType.toString().split('.').last,
      'options': options,
      'correct_answer': correctAnswer,
      'explanation': explanation,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
