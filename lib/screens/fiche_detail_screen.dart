import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/fiche.dart';
import '../models/question.dart';
import '../models/attachment.dart';
import '../services/question_service.dart';
import '../services/attachment_service.dart';
import 'create_question_screen.dart';
import 'view_questions_screen.dart';

class FicheDetailScreen extends StatefulWidget {
  final Fiche fiche;
  const FicheDetailScreen({super.key, required this.fiche});

  @override
  State<FicheDetailScreen> createState() => _FicheDetailScreenState();
}

class _FicheDetailScreenState extends State<FicheDetailScreen> {
  final QuestionService _questionService = QuestionService();
  final AttachmentService _attachmentService = AttachmentService();
  
  List<Question> _questions = [];
  List<Attachment> _attachments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final [questions, attachments] = await Future.wait([
        _questionService.getQuestions(widget.fiche.id),
        _attachmentService.getAttachments(widget.fiche.id),
      ]);
      
      setState(() {
        _questions = questions;
        _attachments = attachments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Erreur lors du chargement: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
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
      _loadData();
    }
  }

  Future<void> _viewQuestions() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewQuestionsScreen(
          fiche: widget.fiche,
          questions: _questions,
        ),
      ),
    );
    _loadData();
  }

  Future<void> _attachFile() async {
    // TODO: Implémenter l'upload de fichiers
    _showError('Fonctionnalité à implémenter');
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.fiche.title),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Contenu'),
              Tab(text: 'Questions (${0})'),
              Tab(text: 'Fichiers (${0})'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateFicheScreen(fiche: widget.fiche),
                  ),
                );
                if (result == true) {
                  Navigator.pop(context, true); // Refresh parent
                }
              },
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  // Contenu tab
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.fiche.summary != null) ...[
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Résumé',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(widget.fiche.summary!),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        if (widget.fiche.keywords.isNotEmpty) ...[
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Mots-clés',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    children: widget.fiche.keywords
                                        .map((keyword) => Chip(label: Text(keyword)))
                                        .toList(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Contenu',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                MarkdownBody(
                                  data: widget.fiche.content,
                                  selectable: true,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Questions tab
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _createQuestion,
                            icon: const Icon(Icons.add),
                            label: const Text('Ajouter une question'),
                          ),
                        ),
                      ),
                      Expanded(
                        child: _questions.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.quiz, size: 64, color: Colors.grey),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'Aucune question ajoutée',
                                      style: TextStyle(fontSize: 18, color: Colors.grey),
                                    ),
                                    const SizedBox(height: 8),
                                    TextButton(
                                      onPressed: _createQuestion,
                                      child: const Text('Ajouter une première question'),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                itemCount: _questions.length,
                                itemBuilder: (context, index) {
                                  final question = _questions[index];
                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 4,
                                    ),
                                    child: ListTile(
                                      title: Text(question.questionText),
                                      subtitle: Text(
                                        'Type: ${question.questionType.name.toUpperCase()}',
                                      ),
                                      trailing: const Icon(Icons.chevron_right),
                                      onTap: _viewQuestions,
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                  // Attachments tab
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _attachFile,
                            icon: const Icon(Icons.attach_file),
                            label: const Text('Joindre un fichier'),
                          ),
                        ),
                      ),
                      Expanded(
                        child: _attachments.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.folder_open, size: 64, color: Colors.grey),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'Aucun fichier joint',
                                      style: TextStyle(fontSize: 18, color: Colors.grey),
                                    ),
                                    const SizedBox(height: 8),
                                    TextButton(
                                      onPressed: _attachFile,
                                      child: const Text('Joindre un premier fichier'),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                itemCount: _attachments.length,
                                itemBuilder: (context, index) {
                                  final attachment = _attachments[index];
                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 4,
                                    ),
                                    child: ListTile(
                                      leading: Icon(_getFileIcon(attachment.fileType)),
                                      title: Text(attachment.fileName),
                                      subtitle: Text(
                                        '${attachment.fileType.name.toUpperCase()} • '
                                        '${attachment.isDownloaded ? "Téléchargé" : "En ligne"}',
                                      ),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.download),
                                        onPressed: attachment.isDownloaded
                                            ? null
                                            : () => _downloadFile(attachment),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ],
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: _createQuestion,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  IconData _getFileIcon(AttachmentType type) {
    switch (type) {
      case AttachmentType.pdf:
        return Icons.picture_as_pdf;
      case AttachmentType.video:
        return Icons.video_library;
      case AttachmentType.youtube:
        return Icons.play_circle;
      case AttachmentType.image:
        return Icons.image;
    }
  }

  Future<void> _downloadFile(Attachment attachment) async {
    // TODO: Implémenter le téléchargement des fichiers
    _showError('Téléchargement à implémenter');
  }
}
