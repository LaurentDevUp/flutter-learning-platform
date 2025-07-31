# Flutter Supabase Learning Platform

Une application Flutter complète de gestion de fiches d'apprentissage avec authentification, éditeur Markdown, questions interactives et gestion de fichiers, utilisant Supabase.

## 🎯 Fonctionnalités principales

### 📚 **Fiches**
- ✅ Créer une fiche = Titre + Cours (markdown) + Résumé + Mots-clés
- ✅ Éditeur Markdown avec aperçu en temps réel
- ✅ Recherche intelligente par titre ou mots-clés
- ✅ Organisation et catégorisation des fiches

### ❓ **Questions**
- ✅ Ajouter des questions-réponses à n'importe quelle fiche
- ✅ Types de questions supportés:
  - **QCM** (choix multiples)
  - **Texte à trous** (réponse exacte)
  - **Texte libre** (réponse ouverte)
  - **Questions avec images**
  - **Questions avec audio**
- ✅ Mode quiz interactif avec feedback immédiat
- ✅ Explications détaillées pour chaque réponse

### 📎 **Fichiers joints**
- ✅ Attacher des fichiers (PDF, vidéo, images, liens YouTube)
- ✅ Téléchargement pour accès hors-ligne
- ✅ Gestion des fichiers avec prévisualisation
- ✅ Support multi-formats avec stockage cloud

### 🔐 **Authentification sécurisée**
- ✅ Inscription/connexion avec email/mot de passe
- ✅ Sessions sécurisées avec Supabase Auth
- ✅ Données utilisateur isolées (RLS activée)

## 🗄️ Structure de la base de données

### Table `fiches`
- `id` (UUID, Primary Key)
- `title` (Text) - Titre de la fiche
- `content` (Text) - Contenu en Markdown
- `summary` (Text) - Résumé de la fiche
- `keywords` (Text[]) - Liste de mots-clés
- `user_id` (UUID, Foreign Key)
- `created_at` (Timestamp)
- `updated_at` (Timestamp)

### Table `questions`
- `id` (UUID, Primary Key)
- `fiche_id` (UUID, Foreign Key)
- `question_text` (Text)
- `question_type` (Enum: qcm, fill_blank, text, image, audio)
- `options` (JSONB) - Options pour QCM
- `correct_answer` (Text)
- `explanation` (Text) - Explication de la réponse
- `created_at` (Timestamp)

### Table `attachments`
- `id` (UUID, Primary Key)
- `fiche_id` (UUID, Foreign Key)
- `file_name` (Text)
- `file_type` (Enum: pdf, video, youtube, image)
- `file_url` (Text)
- `local_path` (Text) - Chemin local après téléchargement
- `file_size` (BigInt)
- `is_downloaded` (Boolean)
- `created_at` (Timestamp)

## 🚀 Installation rapide

### 1. Configuration Supabase
```sql
-- Créer les tables
CREATE TABLE fiches (...);
CREATE TABLE questions (...);
CREATE TABLE attachments (...);

-- Activer RLS et politiques de sécurité
-- (script complet fourni dans le code)
```

### 2. Configuration Flutter
```bash
# Cloner et installer
git clone <repository-url>
cd flutter_project
flutter pub get

# Lancer l'application
flutter run -d chrome      # Web
flutter run -d android     # Android
flutter run -d windows     # Windows
```

## 🏗️ Architecture du projet

```
lib/
├── models/
│   ├── fiche.dart              # Modèle Fiche
│   ├── question.dart           # Modèle Question
│   └── attachment.dart         # Modèle Attachment
├── screens/
│   ├── auth_screen.dart        # Authentification
│   ├── fiches_screen.dart      # Liste des fiches
│   ├── create_fiche_screen.dart # Création fiche
│   ├── fiche_detail_screen.dart # Détail fiche
│   ├── create_question_screen.dart # Création questions
│   └── view_questions_screen.dart # Quiz interactif
├── services/
│   ├── auth_service.dart       # Authentification
│   ├── fiche_service.dart      # CRUD fiches
│   ├── question_service.dart   # CRUD questions
│   └── attachment_service.dart # Gestion fichiers
└── main.dart                  # Point d'entrée
```

## 📱 Utilisation

### Créer une fiche
1. Connectez-vous avec votre compte
2. Cliquez sur "+" pour créer une nouvelle fiche
3. Remplissez:
   - **Titre** (obligatoire)
   - **Contenu** en Markdown avec aperçu
   - **Résumé** (optionnel)
   - **Mots-clés** (séparés par virgules)
4. Sauvegardez

### Ajouter des questions
1. Ouvrez une fiche
2. Allez dans l'onglet "Questions"
3. Cliquez sur "+" pour ajouter une question
4. Choisissez le type et remplissez les champs

### Mode quiz
1. Dans le détail d'une fiche, onglet "Questions"
2. Cliquez sur "Commencer le quiz"
3. Répondez aux questions et obtenez un feedback immédiat

### Gestion des fichiers
1. Dans le détail d'une fiche, onglet "Fichiers"
2. Joignez des fichiers de différents formats
3. Téléchargez pour accès hors-ligne

## 🎨 Interface utilisateur

### Écrans principaux
- **Auth Screen**: Connexion/inscription élégante
- **Fiches List**: Vue en grille avec recherche
- **Create Fiche**: Éditeur Markdown avec aperçu
- **Fiche Detail**: Vue en onglets (Contenu, Questions, Fichiers)
- **Quiz Mode**: Interface interactive avec feedback

### Thème
- Design Material 3 moderne
- Support du mode sombre
- Responsive pour tous les écrans
- Animations fluides

## 🔧 Scripts de développement

```bash
# Lancer le serveur de développement
flutter run -d chrome --hot

# Build pour production
flutter build web --release
flutter build apk --release

# Tests
flutter test
flutter analyze
```

## 🔄 Fonctionnalités futures

### Phase 2
- [ ] Synchronisation offline complète
- [ ] Partage de fiches entre utilisateurs
- [ ] Statistiques de progression détaillées
- [ ] Mode révision avec algorithme SM2
- [ ] Support audio complet

### Phase 3
- [ ] Export vers PDF/Anki
- [ ] Import depuis d'autres plateformes
- [ ] Quiz chronométrés
- [ ] Mode présentation
- [ ] Collaboration en temps réel

## 📚 Ressources

- [Documentation Flutter](https://flutter.dev/docs)
- [Documentation Supabase](https://supabase.com/docs)
- [Markdown Guide](https://www.markdownguide.org/)
- [Flutter Markdown](https://pub.dev/packages/flutter_markdown)

## 🤝 Contribution

1. Fork le projet
2. Créer une branche (`git checkout -b feature/AmazingFeature`)
3. Commit vos changements (`git commit -m 'Add AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

## 📄 Licence

MIT License - voir le fichier LICENSE pour plus de détails

## 🆘 Support

Pour toute question ou problème, ouvrez une issue sur GitHub ou contactez l'équipe de développement.
