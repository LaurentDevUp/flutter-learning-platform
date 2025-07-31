import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/fiche.dart';
import '../services/fiche_service.dart';

class CreateFicheScreen extends StatefulWidget {
  final Fiche? fiche;
  const CreateFicheScreen({super.key, this.fiche});

  @override
  State<CreateFicheScreen> createState() => _CreateFicheScreenState();
}

class _CreateFicheScreenState extends State<CreateFicheScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _summaryController = TextEditingController();
  final _keywordsController = TextEditingController();
  
  final FicheService _ficheService = FicheService();
  bool _isLoading = false;
  bool _isPreview = false;

  @override
  void initState() {
    super.initState();
    if (widget.fiche != null) {
      _titleController.text = widget.fiche!.title;
      _contentController.text = widget.fiche!.content;
      _summaryController.text = widget.fiche!.summary ?? '';
      _keywordsController.text = widget.fiche!.keywords.join(', ');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _summaryController.dispose();
    _keywordsController.dispose();
    super.dispose();
  }

  Future<void> _saveFiche() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final keywords = _keywordsController.text
          .split(',')
          .map((k) => k.trim())
          .where((k) => k.isNotEmpty)
          .toList();

      if (widget.fiche == null) {
        // Create new fiche
        await _ficheService.createFiche(
          title: _titleController.text,
          content: _contentController.text,
          summary: _summaryController.text.isEmpty ? null : _summaryController.text,
          keywords: keywords,
        );
      } else {
        // Update existing fiche
        await _ficheService.updateFiche(
          id: widget.fiche!.id,
          title: _titleController.text,
          content: _contentController.text,
          summary: _summaryController.text.isEmpty ? null : _summaryController.text,
          keywords: keywords,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.fiche == null ? 'Créer une fiche' : 'Modifier la fiche'),
        actions: [
          IconButton(
            icon: Icon(_isPreview ? Icons.edit : Icons.preview),
            onPressed: () => setState(() => _isPreview = !_isPreview),
            tooltip: _isPreview ? 'Mode édition' : 'Mode aperçu',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Titre *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un titre';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _summaryController,
                      decoration: const InputDecoration(
                        labelText: 'Résumé',
                        border: OutlineInputBorder(),
                        helperText: 'Brève description de la fiche',
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _keywordsController,
                      decoration: const InputDecoration(
                        labelText: 'Mots-clés',
                        border: OutlineInputBorder(),
                        helperText: 'Séparez les mots-clés par des virgules',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      height: 400,
                      child: _isPreview
                          ? Markdown(
                              data: _contentController.text,
                              selectable: true,
                            )
                          : TextFormField(
                              controller: _contentController,
                              decoration: const InputDecoration(
                                labelText: 'Contenu (Markdown) *',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(12),
                              ),
                              maxLines: null,
                              expands: true,
                              textAlignVertical: TextAlignVertical.top,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Veuillez entrer le contenu';
                                }
                                return null;
                              },
                            ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveFiche,
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
                                widget.fiche == null ? 'Créer la fiche' : 'Mettre à jour',
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
