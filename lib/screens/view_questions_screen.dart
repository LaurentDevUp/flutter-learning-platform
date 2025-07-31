import 'package:flutter/material.dart';
import '../models/fiche.dart';
import '../models/question.dart';
import '../services/question_service.dart';
import 'create_question_screen.dart';

class ViewQuestionsScreen extends StatefulWidget {
  final Fiche fiche;
  final List<Question> questions;
  const ViewQuestionsScreen({super.key, required this.fiche, required this.questions});

  @override
  State<ViewQuestionsScreen> createState() => _ViewQuestionsScreenState();
}

class _ViewQuestionsScreenState extends State<ViewQuestionsScreen> {
  final QuestionService _questionService = QuestionService();
  late List<Question> _questions = List.from(widget.questions);
  int? _currentQuestionIndex;
  Map<String, String> _userAnswers = {};
  Map<String, bool> _results = {};

  @override
  Widget build(BuildContext context) {
    if (_currentQuestionIndex == null) {
      return _buildQuestionList();
    } else {
      return _buildQuestionView();
    }
  }

  Widget _buildQuestionList() {
    return Scaffold(
      appBar: AppBar(
        title: Text('Questions - ${widget.fiche.title}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _createQuestion,
          ),
        ],
      ),
      body: _questions.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.quiz, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Aucune question disponible',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _createQuestion,
                    icon: const Icon(Icons.add),
                    label: const Text('Ajouter une question'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _questions.length,
              itemBuilder: (context, index) {
                final question = _questions[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(question.questionText),
                    subtitle: Text(
                      'Type: ${question.questionType.name.toUpperCase()}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editQuestion(question),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteQuestion(question),
                        ),
                      ],
                    ),
                    onTap: () {
                      setState(() {
                        _currentQuestionIndex = index;
                      });
                    },
                  ),
                );
              },
            ),
    );
  }

  Widget _buildQuestionView() {
    final question = _questions[_currentQuestionIndex!];
    final hasAnswered = _userAnswers.containsKey(question.id);
    final isCorrect = _results[question.id];

    return Scaffold(
      appBar: AppBar(
        title: Text('Question ${_currentQuestionIndex! + 1}/${_questions.length}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              _currentQuestionIndex = null;
            });
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question.questionText,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _buildQuestionContent(question),
            if (hasAnswered) ...[
              const SizedBox(height: 24),
              Card(
                color: isCorrect! ? Colors.green[50] : Colors.red[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isCorrect ? Icons.check_circle : Icons.cancel,
                            color: isCorrect ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isCorrect ? 'Bonne réponse!' : 'Mauvaise réponse',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isCorrect ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                      if (question.explanation != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Explication: ${question.explanation}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_currentQuestionIndex! > 0)
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _currentQuestionIndex = _currentQuestionIndex! - 1;
                    });
                  },
                  child: const Text('Précédent'),
                )
              else
                const SizedBox(width: 80),
              Text('${_currentQuestionIndex! + 1}/${_questions.length}'),
              if (_currentQuestionIndex! < _questions.length - 1)
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _currentQuestionIndex = _currentQuestionIndex! + 1;
                    });
                  },
                  child: const Text('Suivant'),
                )
              else
                const SizedBox(width: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionContent(Question question) {
    switch (question.questionType) {
      case QuestionType.qcm:
        return _buildQCMQuestion(question);
      case QuestionType.fillBlank:
        return _buildFillBlankQuestion(question);
      case QuestionType.text:
        return _buildTextQuestion(question);
      case QuestionType.image:
      case QuestionType.audio:
        return _buildMediaQuestion(question);
    }
  }

  Widget _buildQCMQuestion(Question question) {
    final hasAnswered = _userAnswers.containsKey(question.id);
    final selectedAnswer = _userAnswers[question.id];

    return Column(
      children: question.options!.map((option) {
        return RadioListTile<String>(
          title: Text(option),
          value: option,
          groupValue: selectedAnswer,
          onChanged: hasAnswered
              ? null
              : (value) {
                  setState(() {
                    _userAnswers[question.id] = value!;
                    _results[question.id] = value == question.correctAnswer;
                  });
                },
        );
      }).toList(),
    );
  }

  Widget _buildFillBlankQuestion(Question question) {
    final hasAnswered = _userAnswers.containsKey(question.id);
    final controller = TextEditingController(text: _userAnswers[question.id] ?? '');

    return Column(
      children: [
        TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Votre réponse',
            border: OutlineInputBorder(),
          ),
          enabled: !hasAnswered,
          onSubmitted: hasAnswered
              ? null
              : (value) {
                  setState(() {
                    _userAnswers[question.id] = value;
                    _results[question.id] = value.toLowerCase().trim() == 
                        question.correctAnswer.toLowerCase().trim();
                  });
                },
        ),
        if (!hasAnswered)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _userAnswers[question.id] = controller.text;
                  _results[question.id] = controller.text.toLowerCase().trim() == 
                      question.correctAnswer.toLowerCase().trim();
                });
              },
              child: const Text('Valider'),
            ),
          ),
      ],
    );
  }

  Widget _buildTextQuestion(Question question) {
    return _buildFillBlankQuestion(question);
  }

  Widget _buildMediaQuestion(Question question) {
    return Column(
      children: [
        const Icon(Icons.image, size: 100, color: Colors.grey),
        const SizedBox(height: 16),
        const Text('Question avec support média'),
        const SizedBox(height: 16),
        _buildFillBlankQuestion(question),
      ],
    );
  }

  Future<void> _createQuestion() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateQuestionScreen(ficheId: widget.fiche.id),
      ),
    );
    
    if (result == true) {
      _loadQuestions();
    }
  }

  Future<void> _editQuestion(Question question) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateQuestionScreen(
          ficheId: widget.fiche.id,
          question: question,
        ),
      ),
    );
    
    if (result == true) {
      _loadQuestions();
    }
  }

  Future<void> _deleteQuestion(Question question) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text('Voulez-vous vraiment supprimer cette question ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _questionService.deleteQuestion(question.id);
        _loadQuestions();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _loadQuestions() async {
    try {
      final questions = await _questionService.getQuestions(widget.fiche.id);
      setState(() {
        _questions = questions;
        _userAnswers.clear();
        _results.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
      );
    }
  }
}
