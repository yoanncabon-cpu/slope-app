import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slope/models/learning_module.dart';
import 'package:slope/models/lesson.dart';
import 'package:slope/providers/progress_provider.dart';

LearningModule _moduleWithLessons(String id, List<String> lessonIds) {
  return LearningModule(
    id: id,
    title: 'Module $id',
    icon: 'icon',
    colorKey: 'actions',
    summary: 'summary',
    level: 'Débutant',
    durationMinutes: 10,
    track: LearningTrack.investment,
    lessons: lessonIds
        .map((lessonId) => Lesson(id: lessonId, title: 'Leçon $lessonId', content: 'content', durationMinutes: 5))
        .toList(),
    quiz: const [],
  );
}

void main() {
  group('ProgressProvider', () {
    test('init() sur des prefs vides : état initial vide et prêt', () async {
      SharedPreferences.setMockInitialValues({});
      final provider = ProgressProvider();

      expect(provider.isReady, isFalse);
      await provider.init();

      expect(provider.isReady, isTrue);
      expect(provider.completedLessons, isEmpty);
      expect(provider.favoriteIdeas, isEmpty);
      expect(provider.favoriteArticles, isEmpty);
    });

    test('setLessonCompleted met à jour la progression et persiste', () async {
      SharedPreferences.setMockInitialValues({});
      final module = _moduleWithLessons('m1', ['l1', 'l2']);

      final provider = ProgressProvider();
      await provider.init();

      expect(provider.isLessonCompleted('l1'), isFalse);
      expect(provider.moduleProgress(module), 0);
      expect(provider.isModuleCompleted(module), isFalse);

      await provider.setLessonCompleted('l1', true);
      expect(provider.isLessonCompleted('l1'), isTrue);
      expect(provider.moduleProgress(module), closeTo(0.5, 1e-9));
      expect(provider.isModuleCompleted(module), isFalse);

      await provider.setLessonCompleted('l2', true);
      expect(provider.moduleProgress(module), closeTo(1.0, 1e-9));
      expect(provider.isModuleCompleted(module), isTrue);

      // Persistance : un nouveau provider relit le même état depuis les prefs.
      final reloaded = ProgressProvider();
      await reloaded.init();
      expect(reloaded.isLessonCompleted('l1'), isTrue);
      expect(reloaded.isLessonCompleted('l2'), isTrue);

      await provider.setLessonCompleted('l1', false);
      expect(provider.isLessonCompleted('l1'), isFalse);
      expect(provider.moduleProgress(module), closeTo(0.5, 1e-9));
    });

    test('recordQuizScore ne garde que le meilleur score', () async {
      SharedPreferences.setMockInitialValues({});
      final provider = ProgressProvider();
      await provider.init();

      expect(provider.quizScore('m1'), isNull);

      await provider.recordQuizScore('m1', 60);
      expect(provider.quizScore('m1'), 60);

      // Un score plus faible n'écrase pas le meilleur score.
      await provider.recordQuizScore('m1', 40);
      expect(provider.quizScore('m1'), 60);

      // Un meilleur score remplace l'ancien.
      await provider.recordQuizScore('m1', 90);
      expect(provider.quizScore('m1'), 90);

      // Persistance.
      final reloaded = ProgressProvider();
      await reloaded.init();
      expect(reloaded.quizScore('m1'), 90);
    });

    test('toggleFavoriteIdea et toggleFavoriteArticle basculent et persistent', () async {
      SharedPreferences.setMockInitialValues({});
      final provider = ProgressProvider();
      await provider.init();

      expect(provider.isFavoriteIdea('idea1'), isFalse);
      await provider.toggleFavoriteIdea('idea1');
      expect(provider.isFavoriteIdea('idea1'), isTrue);
      await provider.toggleFavoriteIdea('idea1');
      expect(provider.isFavoriteIdea('idea1'), isFalse);

      expect(provider.isFavoriteArticle('article1'), isFalse);
      await provider.toggleFavoriteArticle('article1');
      expect(provider.isFavoriteArticle('article1'), isTrue);

      final reloaded = ProgressProvider();
      await reloaded.init();
      expect(reloaded.isFavoriteArticle('article1'), isTrue);
      expect(reloaded.isFavoriteIdea('idea1'), isFalse);
    });

    test('overallProgress et completedModulesCount sur plusieurs modules', () async {
      SharedPreferences.setMockInitialValues({});
      final provider = ProgressProvider();
      await provider.init();

      final moduleA = _moduleWithLessons('a', ['a1', 'a2']);
      final moduleB = _moduleWithLessons('b', ['b1', 'b2']);
      final modules = [moduleA, moduleB];

      expect(provider.overallProgress(modules), 0);
      expect(provider.completedModulesCount(modules), 0);

      await provider.setLessonCompleted('a1', true);
      await provider.setLessonCompleted('a2', true);
      expect(provider.overallProgress(modules), closeTo(0.5, 1e-9));
      expect(provider.completedModulesCount(modules), 1);

      await provider.setLessonCompleted('b1', true);
      await provider.setLessonCompleted('b2', true);
      expect(provider.overallProgress(modules), closeTo(1.0, 1e-9));
      expect(provider.completedModulesCount(modules), 2);
    });
  });
}
