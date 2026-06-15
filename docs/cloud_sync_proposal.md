# Proposition : compte utilisateur & synchronisation cloud

Ce document propose une architecture pour permettre aux utilisateurs de Slope
de retrouver leur progression (leçons terminées, scores de quiz, favoris) sur
plusieurs appareils. **Aucune implémentation n'est faite à ce stade** : c'est
une référence pour une future passe de développement, qui nécessite des
décisions et des comptes externes (voir section "Étapes hors-Claude Code").

## État actuel

`ProgressProvider` (`lib/providers/progress_provider.dart`) stocke tout en
local via `SharedPreferences` :
- `completed_lessons` (liste d'IDs de leçons terminées)
- `quiz_scores` (Map moduleId → meilleur score en %)
- `favorite_ideas` / `favorite_articles` (listes d'IDs)

C'est 100 % local : si l'utilisateur change d'appareil ou désinstalle
l'application, toute la progression est perdue.

## Recommandation : Firebase (FlutterFire)

**Firebase Auth + Cloud Firestore**, via le package officiel FlutterFire.

Pourquoi Firebase plutôt que Supabase :
- Intégration "first-class" avec Flutter (packages officiels maintenus par
  Google, `flutterfire configure` génère toute la configuration
  Android/iOS/Web automatiquement).
- Offre gratuite (plan Spark) largement suffisante pour ce volume de données :
  quelques documents de quelques Ko par utilisateur.
- Aucun serveur à maintenir, aucune base de données à administrer.
- Authentification anonyme disponible nativement, ce qui permet de
  synchroniser la progression *sans forcer la création d'un compte* dès le
  premier lancement, puis de "lier" un compte email/Google plus tard sans
  perdre les données.

Alternative envisageable : **Supabase** (Postgres + Auth open-source,
auto-hébergeable). Pertinent si l'on préfère du SQL, l'auto-hébergement, ou
si une autre partie du produit a déjà besoin d'un backend Postgres. Pour le
besoin actuel (quelques champs clé-valeur par utilisateur), Firebase reste le
choix le plus simple et le moins coûteux en effort.

## Architecture proposée

Introduire une interface `ProgressRepository` reprenant les méthodes
actuelles de `ProgressProvider` (lecture/écriture de `completed_lessons`,
`quiz_scores`, `favorite_ideas`, `favorite_articles`), avec deux
implémentations :

- **`LocalProgressRepository`** : wrapper de l'implémentation
  `SharedPreferences` actuelle. Utilisée hors-ligne ou quand aucun utilisateur
  n'est connecté.
- **`CloudProgressRepository`** : Firestore, un document par utilisateur
  (ex. `users/{uid}/progress`), contenant les mêmes champs.

`ProgressProvider` devient **local-first** :
1. Toute écriture (`setLessonCompleted`, `toggleFavoriteIdea`, etc.) est
   d'abord appliquée en local (comme aujourd'hui — réactivité immédiate, ça
   fonctionne hors-ligne).
2. Si un utilisateur est connecté (`AuthProvider` basé sur `firebase_auth`),
   l'écriture est répliquée vers `CloudProgressRepository` en arrière-plan
   (fire-and-forget, avec gestion d'erreur silencieuse — pas de blocage UI).
3. Au login (ou à la connexion d'un compte précédemment anonyme), on
   fusionne l'état local et l'état cloud : pour des sets (`completed_lessons`,
   favoris) on fait l'union ; pour les scores de quiz on garde le meilleur
   des deux par module. Le résultat fusionné est réécrit localement et dans
   le cloud.

Cette approche évite une refonte : l'UI continue d'utiliser
`ProgressProvider` exactement comme aujourd'hui (mêmes méthodes, mêmes
signatures), seule son implémentation interne change.

## Étapes hors-Claude Code (décisions/comptes externes requis)

Ces étapes nécessitent des actions manuelles côté Firebase Console et ne
peuvent pas être faites depuis le code :

1. Créer un projet Firebase (console.firebase.google.com).
2. Activer **Authentication** et choisir les providers souhaités (anonyme
   pour démarrer, puis email/mot de passe et/ou Google selon le besoin produit).
3. Activer **Cloud Firestore** (mode production, règles de sécurité à définir
   pour que chaque utilisateur ne lise/écrive que son propre document).
4. Exécuter `flutterfire configure` depuis le projet Flutter — génère
   `firebase_options.dart` et les fichiers de configuration natifs
   (Android `google-services.json`, iOS `GoogleService-Info.plist`, config Web).
5. Ajouter les dépendances au `pubspec.yaml` : `firebase_core`,
   `firebase_auth`, `cloud_firestore`.

## Effort estimé par étape

| Étape | Effort estimé |
|---|---|
| Configuration initiale Firebase (étapes 1-5 ci-dessus) | 0,5 à 1 jour (selon familiarité avec la console Firebase) |
| `ProgressRepository` (interface + `LocalProgressRepository` + `CloudProgressRepository`) | 0,5 jour |
| `AuthProvider` + UI de connexion (anonyme → email/Google, écran de paramètres) | 1 à 2 jours |
| Logique de synchronisation et fusion au login | 0,5 à 1 jour |
| Tests (repository cloud avec émulateur Firestore, fusion, `ProgressProvider` mis à jour) | 0,5 à 1 jour |

**Total estimé : 3 à 5,5 jours**, hors configuration manuelle préalable.

Cette estimation suppose que la configuration Firebase (étapes hors-Claude
Code ci-dessus) est faite en amont par l'utilisateur.
