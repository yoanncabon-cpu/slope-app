import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/learning_module.dart';

/// Gère et persiste la progression de l'utilisateur :
/// leçons terminées, scores de quiz et idées favorites.
class ProgressProvider extends ChangeNotifier {
  static const _keyCompletedLessons = 'completed_lessons';
  static const _keyQuizScores = 'quiz_scores';
  static const _keyFavoriteIdeas = 'favorite_ideas';

  SharedPreferences? _prefs;

  final Set<String> _completedLessons = {};
  final Map<String, int> _quizScores = {}; // moduleId -> pourcentage 0-100
  final Set<String> _favoriteIdeas = {};

  bool _isReady = false;
  bool get isReady => _isReady;

  Set<String> get completedLessons => _completedLessons;
  Set<String> get favoriteIdeas => _favoriteIdeas;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();

    _completedLessons.addAll(
      _prefs?.getStringList(_keyCompletedLessons) ?? [],
    );
    _favoriteIdeas.addAll(
      _prefs?.getStringList(_keyFavoriteIdeas) ?? [],
    );

    final rawScores = _prefs?.getString(_keyQuizScores);
    if (rawScores != null) {
      final decoded = json.decode(rawScores) as Map<String, dynamic>;
      decoded.forEach((key, value) => _quizScores[key] = value as int);
    }

    _isReady = true;
    notifyListeners();
  }

  bool isLessonCompleted(String lessonId) =>
      _completedLessons.contains(lessonId);

  Future<void> setLessonCompleted(String lessonId, bool completed) async {
    if (completed) {
      _completedLessons.add(lessonId);
    } else {
      _completedLessons.remove(lessonId);
    }
    await _prefs?.setStringList(_keyCompletedLessons, _completedLessons.toList());
    notifyListeners();
  }

  double moduleProgress(LearningModule module) {
    if (module.lessons.isEmpty) return 0;
    final done = module.lessons
        .where((l) => _completedLessons.contains(l.id))
        .length;
    return done / module.lessons.length;
  }

  bool isModuleCompleted(LearningModule module) =>
      moduleProgress(module) >= 1.0;

  int? quizScore(String moduleId) => _quizScores[moduleId];

  Future<void> recordQuizScore(String moduleId, int percent) async {
    final current = _quizScores[moduleId];
    if (current == null || percent > current) {
      _quizScores[moduleId] = percent;
      await _prefs?.setString(_keyQuizScores, json.encode(_quizScores));
      notifyListeners();
    }
  }

  bool isFavoriteIdea(String ideaId) => _favoriteIdeas.contains(ideaId);

  Future<void> toggleFavoriteIdea(String ideaId) async {
    if (_favoriteIdeas.contains(ideaId)) {
      _favoriteIdeas.remove(ideaId);
    } else {
      _favoriteIdeas.add(ideaId);
    }
    await _prefs?.setStringList(_keyFavoriteIdeas, _favoriteIdeas.toList());
    notifyListeners();
  }

  /// Calcule la progression globale (0.0 à 1.0) sur l'ensemble des modules fournis.
  double overallProgress(List<LearningModule> modules) {
    final totalLessons = modules.fold<int>(0, (sum, m) => sum + m.lessons.length);
    if (totalLessons == 0) return 0;
    final done = modules.fold<int>(
      0,
      (sum, m) =>
          sum + m.lessons.where((l) => _completedLessons.contains(l.id)).length,
    );
    return done / totalLessons;
  }

  int completedModulesCount(List<LearningModule> modules) =>
      modules.where(isModuleCompleted).length;
}
