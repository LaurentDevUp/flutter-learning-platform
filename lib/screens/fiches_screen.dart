import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/fiche.dart';
import '../services/fiche_service.dart';
import '../services/auth_service.dart';
import 'create_fiche_screen.dart';
import 'fiche_detail_screen.dart';

class FichesScreen extends StatefulWidget {
  const FichesScreen({super.key});

  @override
  State<FichesScreen> createState() => _FichesScreenState();
}

class _FichesScreenState extends State<FichesScreen> {
  final FicheService _ficheService = FicheService();
  final AuthService _authService = AuthService();
  final TextEditingController _searchController = TextEditingController();
  
  List<Fiche> _fiches = [];
  List<Fiche> _filteredFiches = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadFiches();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFiches() async {
    try {
      final fiches = await _ficheService.getFiches();
      setState(() {
        _fiches = fiches;
        _filteredFiches = fiches;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Erreur lors du chargement des fiches: $e');
    }
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      if (_searchQuery.isEmpty) {
        _filteredFiches = _fiches;
      } else {
        _filteredFiches = _fiches.where((fiche) {
          return fiche.title.toLowerCase().contains(_searchQuery) ||
                 fiche.keywords.any((keyword) => 
                   keyword.toLowerCase().contains(_searchQuery));
        }).toList();
      }
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _createNewFiche() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateFicheScreen()),
    );
    
    if (result == true) {
      _loadFiches();
    }
  }

  Future<void> _viewFiche(Fiche fiche) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FicheDetailScreen(fiche: fiche),
      ),
    );
    _loadFiches(); // Refresh after potential updates
  }

  Future<void> _deleteFiche(Fiche fiche) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Voulez-vous vraiment supprimer "${fiche.title}" ?'),
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
        await _ficheService.deleteFiche(fiche.id);
        _loadFiches();
      } catch (e) {
        _showError('Erreur lors de la suppression: $e');
      }
    }
  }

  Future<void> _signOut() async {
    await _authService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Fiches'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
            tooltip: 'Déconnexion',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Rechercher des fiches...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredFiches.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.note_add, size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'Aucune fiche créée'
                                  : 'Aucune fiche trouvée',
                              style: const TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredFiches.length,
                        itemBuilder: (context, index) {
                          final fiche = _filteredFiches[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: ListTile(
                              title: Text(fiche.title),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (fiche.summary != null) ...[
                                    Text(
                                      fiche.summary!,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                  ],
                                  if (fiche.keywords.isNotEmpty) ...[
                                    Wrap(
                                      spacing: 4,
                                      children: fiche.keywords
                                          .take(3)
                                          .map((keyword) => Chip(
                                                label: Text(keyword),
                                                materialTapTargetSize:
                                                    MaterialTapTargetSize.shrink,
                                                labelStyle: const TextStyle(
                                                  fontSize: 12,
                                                ),
                                              ))
                                          .toList(),
                                    ),
                                  ],
                                ],
                              ),
                              trailing: PopupMenuButton(
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Text('Modifier'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Text('Supprimer'),
                                  ),
                                ],
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    _viewFiche(fiche);
                                  } else if (value == 'delete') {
                                    _deleteFiche(fiche);
                                  }
                                },
                              ),
                              onTap: () => _viewFiche(fiche),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewFiche,
        child: const Icon(Icons.add),
      ),
    );
  }
}
