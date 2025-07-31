import 'package:flutter/material.dart';
import '../models/question.dart';
import '../services/question_service.dart';

class CreateQuestionScreen extends StatefulWidget {
  final String ficheId;
  final Question? question;
  const CreateQuestionScreen({super.key, required this.ficheId, this.question});

  @override
  State<CreateQuestionScreen> createState() => _CreateQuestionScreenState();
}

class _CreateQuestionScreenState extends State<CreateQuestionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final _correctAnswerController = TextEditingController();
  final _explanationController = TextEditingController();
  final _optionsController = TextEditingController();
  
  final QuestionService _questionService = QuestionService();
  QuestionType _selectedType = QuestionType.qcm;
  List<String> _options = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.question != null) {
      _questionController.text = widget.question!.questionText;
      _correctAnswerController.text = widget.question!.correctAnswer;
      _explanationController.text = widget.question!.explanation ?? '';
      _selectedType = widget.question!.questionType;
      _options = widget.question!.options ?? [];
      _optionsController.text = _options.join('\n');
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    _correctAnswerController.dispose();
    _explanationController.dispose();
    _optionsController.dispose();
    super.dispose();
  }

  Future<void> _saveQuestion() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final options = _selectedType == QuestionType.qcm
          ? _optionsController.text
              .split('\n')
              .map((o) => o.trim())
              .where((o) => o.isNotEmpty)
              .toList()
          : null;

      if (widget.question == null) {
        // Create new question
        await _questionService.createQuestion(
          ficheId: widget.ficheId,
          questionText: _questionController.text,
          questionType: _selectedType,
          options: options,
          correctAnswer: _correctAnswerController.text,
          explanation: _explanationController.text.isEmpty 
              ? null 
              : _explanationController.text,
        );
      } else {
        // Update existing question
        await _questionService.updateQuestion(
          id: widget.question!.id,
          questionText: _questionController.text,
          questionType: _selectedType,
          options: options,
          correctAnswer: _correctAnswerController.text,
          explanation: _explanationController.text.isEmpty 
              ? null 
              : _explanationController.text,
        );
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildOptionsField() {
    if (_selectedType != QuestionType.qcm) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        TextFormField(
          controller: _optionsController,
          decoration: const InputDecoration(
            labelText: 'Options (une par ligne) *',
            border: OutlineInputBorder(),
            helperText: 'Entrez une option par ligne',
          ),
          maxLines: 4,
          validator: (value) {
            if (_selectedType == QuestionType.qcm) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer au moins une option';
              }
              final options = value
                  .split('\n')
                  .map((o) => o.trim())
                  .where((o) => o.isNotEmpty)
                  .toList();
              if (options.length < 2) {
                return 'Veuillez entrer au moins 2 options';
              }
            }
            return null;
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.question == null ? 'Créer une question' : 'Modifier la question'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<QuestionType>(
                      value: _selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Type de question *',
                        border: OutlineInputBorder(),
                      ),
                      items: QuestionType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type.name.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedType = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _questionController,
                      decoration: const InputDecoration(
                        labelText: 'Question *',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer la question';
                        }
                        return null;
                      },
                    ),
                    _buildOptionsField(),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _correctAnswerController,
                      decoration: const InputDecoration(
                        labelText: 'Réponse correcte *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer la réponse correcte';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _explanationController,
                      decoration: const InputDecoration(
                        labelText: 'Explication (optionnelle)',
                        border: OutlineInputBorder(),
                        helperText: 'Explication détaillée de la réponse',
                      ),
                      maxLines: 4,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveQuestion,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(
                                widget.question == null ? 'Créer la question' : 'Mettre à jour',
                                style: const TextStyle(fontSize: 16),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
