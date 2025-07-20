# Configuration Supabase pour Hockey Français

## 1. Création du projet Supabase

1. Allez sur [supabase.io](https://supabase.io)
2. Créez un nouveau projet
3. Notez votre URL et votre clé anonyme

## 2. Configuration dans l'application

1. Ouvrez `lib/config/supabase_config.dart`
2. Remplacez les valeurs par défaut :

```dart
static const String supabaseUrl = 'https://votre-projet-id.supabase.co';
static const String supabaseAnonKey = 'votre-clé-anonyme-ici';
```

## 3. Création des tables

1. Allez dans l'éditeur SQL de votre projet Supabase
2. Copiez et exécutez le contenu de `createTablesSQL` depuis `lib/config/supabase_config.dart`

## 4. Insertion des données d'exemple

1. Exécutez le contenu de `sampleDataSQL` pour insérer les équipes de la Ligue Magnus

## 5. Configuration de l'authentification

1. Dans le tableau de bord Supabase, allez dans Authentication > Settings
2. Activez les fournisseurs d'authentification souhaités (Email/Password est activé par défaut)
3. Configurez les URLs de redirection si nécessaire

## 6. Configuration du stockage (optionnel)

1. Dans Storage, créez les buckets suivants :
   - `avatars` (pour les avatars utilisateurs)
   - `team-logos` (pour les logos d'équipes)

## 7. Policies RLS (Row Level Security)

Les policies sont automatiquement créées par le script SQL :

- Les utilisateurs peuvent voir et modifier leur propre profil
- Les utilisateurs peuvent voir leurs propres paris
- Les équipes et matchs sont visibles par tous

## 8. Mode hors ligne

L'application fonctionne en mode hybride :
- Si Supabase est disponible, les données sont synchronisées
- Sinon, l'application utilise les données locales avec SharedPreferences

## 9. Test de la configuration

1. Lancez l'application
2. Essayez de créer un compte ou de vous connecter
3. Vérifiez que les données sont bien synchronisées dans Supabase

## Structure des tables

### Teams
- `id` : UUID (PK)
- `name` : Nom de l'équipe
- `city` : Ville
- `arena` : Nom de la patinoire
- `logo_url` : URL du logo
- `points`, `wins`, `losses`, etc. : Statistiques
- `players`, `staff` : Listes des joueurs et staff

### Matches
- `id` : UUID (PK)
- `home_team_id`, `away_team_id` : Références aux équipes
- `date` : Date et heure du match
- `status` : scheduled, live, finished
- `home_score`, `away_score` : Scores
- `venue` : Lieu du match

### User_profiles
- `id` : UUID (PK, référence à auth.users)
- `username` : Nom d'utilisateur
- `favorite_team_id` : Équipe favorite
- `total_pucks` : Monnaie virtuelle
- `successful_bets`, `total_bets` : Statistiques des paris
- `ranking` : Classement

### Bets
- `id` : UUID (PK)
- `user_id` : Référence à l'utilisateur
- `match_id` : Référence au match
- `prediction` : Prédiction (home, away, draw)
- `pucks_wagered` : Nombre de pucks pariés
- `status` : pending, won, lost
- `odds` : Cotes du pari

## Fonctionnalités Supabase utilisées

1. **Authentification** : Inscription, connexion, déconnexion
2. **Base de données** : Stockage des équipes, matchs, profils, paris
3. **Temps réel** : Mises à jour en temps réel des matchs
4. **Sécurité** : Row Level Security pour protéger les données
5. **Stockage** : Avatars et logos d'équipes
6. **Edge Functions** : Calculs côté serveur (optionnel)

## Dépannage

### Erreur de connexion
- Vérifiez que les URLs et clés sont correctes
- Vérifiez que votre projet Supabase est actif

### Erreurs de base de données
- Vérifiez que les tables sont créées
- Vérifiez les policies RLS

### Mode hors ligne
- L'application basculera automatiquement en mode hors ligne si Supabase n'est pas disponible
- Les données locales seront utilisées avec SharedPreferences