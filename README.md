# Flutter Supabase Todos

Une application Flutter complète avec authentification et base de données en temps réel utilisant Supabase.

## Fonctionnalités

- ✅ **Authentification** : Inscription et connexion avec email/mot de passe
- ✅ **Base de données** : CRUD complet pour les todos
- ✅ **Temps réel** : Mise à jour instantanée des données
- ✅ **Sécurité** : Row Level Security (RLS) activée
- ✅ **Multi-plateforme** : Support Web, Android, iOS, Windows, Linux, macOS

## Configuration Supabase

### Variables d'environnement

Les clés d'API sont déjà configurées dans `lib/supabase_config.dart` :

```dart
static const String supabaseUrl = 'https://fnoncwektdnxxouyvatn.supabase.co';
static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
```

### Structure de la base de données

La table `todos` contient :
- `id` (UUID) : Identifiant unique
- `title` (TEXT) : Titre de la tâche
- `description` (TEXT) : Description optionnelle
- `completed` (BOOLEAN) : État de complétion
- `user_id` (UUID) : Référence à l'utilisateur
- `created_at` (TIMESTAMP) : Date de création
- `updated_at` (TIMESTAMP) : Date de mise à jour

## Installation et lancement

### Prérequis

- Flutter 3.27.3 ou supérieur
- Dart 3.6.1 ou supérieur
- Java 17-21 (pour Android)

### Étapes d'installation

1. **Cloner le projet**
   ```bash
   git clone [URL_DU_REPO]
   cd flutter_project
   ```

2. **Installer les dépendances**
   ```bash
   flutter pub get
   ```

3. **Lancer l'application**
   ```bash
   # Web
   flutter run -d chrome
   
   # Windows
   flutter run -d windows
   
   # Android
   flutter run -d android
   ```

## Architecture du projet

```
lib/
├── models/
│   └── todo.dart          # Modèle de données Todo
├── screens/
│   ├── auth_screen.dart   # Écran d'authentification
│   └── todos_screen.dart  # Écran principal des todos
├── services/
│   ├── auth_service.dart  # Service d'authentification
│   ├── database_service.dart # Service de base de données général
│   └── todo_service.dart  # Service spécifique aux todos
├── supabase_config.dart   # Configuration Supabase
└── main.dart             # Point d'entrée de l'application
```

## Utilisation

### 1. Créer un compte
- Ouvrez l'application
- Cliquez sur "Pas de compte ? S'inscrire"
- Entrez votre email et mot de passe
- Validez votre email via le lien reçu

### 2. Gérer vos todos
- **Ajouter** : Cliquez sur le bouton "+" flottant
- **Marquer comme complété** : Cochez la case
- **Modifier** : Cliquez sur le titre ou description
- **Supprimer** : Cliquez sur l'icône de suppression

### 3. Déconnexion
- Cliquez sur l'icône de déconnexion dans l'AppBar

## Développement

### Ajouter une nouvelle table

1. Créer la table dans Supabase Dashboard
2. Créer le modèle dans `lib/models/`
3. Créer le service dans `lib/services/`
4. Implémenter l'interface utilisateur

### Politiques de sécurité

Les politiques RLS sont activées pour :
- Chaque utilisateur ne voit que ses propres données
- Les opérations CRUD sont limitées aux propriétaires
- Les utilisateurs doivent être authentifiés

## Déploiement

### Web
```bash
flutter build web --release
```

### Android
```bash
flutter build apk --release
```

## Ressources supplémentaires

- [Documentation Supabase](https://supabase.com/docs)
- [Documentation Flutter](https://docs.flutter.dev/)
- [Guide Supabase Flutter](https://supabase.com/docs/guides/getting-started/quickstarts/flutter)
