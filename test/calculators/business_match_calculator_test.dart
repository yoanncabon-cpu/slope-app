import 'package:flutter_test/flutter_test.dart';
import 'package:slope/calculators/business_match_calculator.dart';
import 'package:slope/models/business_idea.dart';

BusinessIdea _idea({
  String id = 'idea',
  String category = 'Test',
  String difficulty = 'Moyen',
  int investmentMin = 1000,
  int investmentMax = 5000,
  int weeklyTimeMin = 10,
  int weeklyTimeMax = 20,
  List<String> skillTags = const [],
}) {
  return BusinessIdea(
    id: id,
    title: 'Idée $id',
    category: category,
    icon: 'lightbulb',
    pitch: 'Pitch $id',
    description: 'Description $id',
    difficulty: difficulty,
    investmentMin: investmentMin,
    investmentMax: investmentMax,
    timeToProfitMonths: 6,
    marketSizeLabel: 'Marché test',
    growthRatePercent: 5.0,
    marketTrendUnit: 'unité',
    marketTrend: const [],
    targetAudience: 'Audience test',
    pros: const [],
    cons: const [],
    firstSteps: const [],
    skillsNeeded: const [],
    weeklyTimeMin: weeklyTimeMin,
    weeklyTimeMax: weeklyTimeMax,
    skillTags: skillTags,
  );
}

void main() {
  group('matchBusinessIdeas - score budget', () {
    test('budget dans la plage -> score maximal (25)', () {
      final idea = _idea(investmentMin: 1000, investmentMax: 5000, difficulty: 'Moyen');
      final answers = BusinessMatchAnswers(
        budget: 3000,
        weeklyHours: 15,
        riskLevel: 'Moyen',
        domains: const {},
        skillTags: const {},
      );

      final result = matchBusinessIdeas(answers: answers, ideas: [idea]).first;

      // 25 (budget) + 20 (temps) + 20 (risque) + 10 (domaine neutre) + 7.5 (compétences neutre)
      expect(result.score, closeTo(82.5, 1e-9));
    });

    test('budget au-dessus de la plage -> score réduit proportionnellement', () {
      final idea = _idea(investmentMin: 1000, investmentMax: 5000, difficulty: 'Moyen');
      final answers = BusinessMatchAnswers(
        budget: 6000, // 20% au-dessus de la borne max (5000)
        weeklyHours: 15,
        riskLevel: 'Moyen',
        domains: const {},
        skillTags: const {},
      );

      final result = matchBusinessIdeas(answers: answers, ideas: [idea]).first;

      // budgetScore = 25 * (1 - 0.2) = 20 -> total = 20 + 20 + 20 + 10 + 7.5
      expect(result.score, closeTo(77.5, 1e-9));
    });

    test('budget en-dessous de la plage -> score réduit proportionnellement', () {
      final idea = _idea(investmentMin: 1000, investmentMax: 5000, difficulty: 'Moyen');
      final answers = BusinessMatchAnswers(
        budget: 500, // 50% en-dessous de la borne min (1000)
        weeklyHours: 15,
        riskLevel: 'Moyen',
        domains: const {},
        skillTags: const {},
      );

      final result = matchBusinessIdeas(answers: answers, ideas: [idea]).first;

      // budgetScore = 25 * (1 - 0.5) = 12.5 -> total = 12.5 + 20 + 20 + 10 + 7.5
      expect(result.score, closeTo(70, 1e-9));
    });
  });

  group('matchBusinessIdeas - score temps hebdo', () {
    test('temps hebdo dans la plage -> score maximal (20)', () {
      final idea = _idea(weeklyTimeMin: 10, weeklyTimeMax: 20, difficulty: 'Moyen');
      final answers = BusinessMatchAnswers(
        budget: 3000,
        weeklyHours: 15,
        riskLevel: 'Moyen',
        domains: const {},
        skillTags: const {},
      );

      final result = matchBusinessIdeas(answers: answers, ideas: [idea]).first;

      expect(result.score, closeTo(82.5, 1e-9));
    });

    test('temps hebdo au-dessus de la plage -> score réduit proportionnellement', () {
      final idea = _idea(weeklyTimeMin: 10, weeklyTimeMax: 20, difficulty: 'Moyen');
      final answers = BusinessMatchAnswers(
        budget: 3000,
        weeklyHours: 30, // 50% au-dessus de la borne max (20)
        riskLevel: 'Moyen',
        domains: const {},
        skillTags: const {},
      );

      final result = matchBusinessIdeas(answers: answers, ideas: [idea]).first;

      // timeScore = 20 * (1 - 0.5) = 10 -> total = 25 + 10 + 20 + 10 + 7.5
      expect(result.score, closeTo(72.5, 1e-9));
    });

    test('temps hebdo en-dessous de la plage -> score réduit proportionnellement', () {
      final idea = _idea(weeklyTimeMin: 10, weeklyTimeMax: 20, difficulty: 'Moyen');
      final answers = BusinessMatchAnswers(
        budget: 3000,
        weeklyHours: 5, // 50% en-dessous de la borne min (10)
        riskLevel: 'Moyen',
        domains: const {},
        skillTags: const {},
      );

      final result = matchBusinessIdeas(answers: answers, ideas: [idea]).first;

      // timeScore = 20 * (1 - 0.5) = 10 -> total = 25 + 10 + 20 + 10 + 7.5
      expect(result.score, closeTo(72.5, 1e-9));
    });
  });

  group('matchBusinessIdeas - score risque/difficulté', () {
    test('niveau de risque identique -> score maximal (20)', () {
      final idea = _idea(difficulty: 'Facile');
      final answers = BusinessMatchAnswers(
        budget: 3000,
        weeklyHours: 15,
        riskLevel: 'Facile',
        domains: const {},
        skillTags: const {},
      );

      final result = matchBusinessIdeas(answers: answers, ideas: [idea]).first;

      expect(result.score, closeTo(82.5, 1e-9));
    });

    test('niveaux opposés (Facile vs Difficile) -> score nul', () {
      final idea = _idea(difficulty: 'Difficile');
      final answers = BusinessMatchAnswers(
        budget: 3000,
        weeklyHours: 15,
        riskLevel: 'Facile',
        domains: const {},
        skillTags: const {},
      );

      final result = matchBusinessIdeas(answers: answers, ideas: [idea]).first;

      // riskScore = 0 -> total = 25 + 20 + 0 + 10 + 7.5
      expect(result.score, closeTo(62.5, 1e-9));
    });

    test('niveaux adjacents (Moyen vs Facile) -> score intermédiaire (10)', () {
      final idea = _idea(difficulty: 'Facile');
      final answers = BusinessMatchAnswers(
        budget: 3000,
        weeklyHours: 15,
        riskLevel: 'Moyen',
        domains: const {},
        skillTags: const {},
      );

      final result = matchBusinessIdeas(answers: answers, ideas: [idea]).first;

      // riskScore = 10 -> total = 25 + 20 + 10 + 10 + 7.5
      expect(result.score, closeTo(72.5, 1e-9));
    });
  });

  group('matchBusinessIdeas - score domaine', () {
    test('domains vide -> score neutre (10) pour toutes les idées', () {
      final idea = _idea(category: 'E-commerce', difficulty: 'Moyen');
      final answers = BusinessMatchAnswers(
        budget: 3000,
        weeklyHours: 15,
        riskLevel: 'Moyen',
        domains: const {},
        skillTags: const {},
      );

      final result = matchBusinessIdeas(answers: answers, ideas: [idea]).first;

      expect(result.score, closeTo(82.5, 1e-9));
    });

    test('catégorie présente dans domains -> score maximal (20)', () {
      final idea = _idea(category: 'E-commerce', difficulty: 'Moyen');
      final answers = BusinessMatchAnswers(
        budget: 3000,
        weeklyHours: 15,
        riskLevel: 'Moyen',
        domains: const {'E-commerce'},
        skillTags: const {},
      );

      final result = matchBusinessIdeas(answers: answers, ideas: [idea]).first;

      // domainScore = 20 -> total = 25 + 20 + 20 + 20 + 7.5
      expect(result.score, closeTo(92.5, 1e-9));
    });

    test('catégorie absente de domains -> score nul', () {
      final idea = _idea(category: 'E-commerce', difficulty: 'Moyen');
      final answers = BusinessMatchAnswers(
        budget: 3000,
        weeklyHours: 15,
        riskLevel: 'Moyen',
        domains: const {'Immobilier'},
        skillTags: const {},
      );

      final result = matchBusinessIdeas(answers: answers, ideas: [idea]).first;

      // domainScore = 0 -> total = 25 + 20 + 20 + 0 + 7.5
      expect(result.score, closeTo(72.5, 1e-9));
    });
  });

  group('matchBusinessIdeas - score compétences', () {
    test('skillTags vide -> score neutre (7.5)', () {
      final idea = _idea(
        difficulty: 'Moyen',
        skillTags: const ['marketing_digital', 'vente_negociation', 'relation_client', 'creation_contenu'],
      );
      final answers = BusinessMatchAnswers(
        budget: 3000,
        weeklyHours: 15,
        riskLevel: 'Moyen',
        domains: const {},
        skillTags: const {},
      );

      final result = matchBusinessIdeas(answers: answers, ideas: [idea]).first;

      expect(result.score, closeTo(82.5, 1e-9));
    });

    test('recoupement partiel -> score proportionnel au nombre de tags communs', () {
      final idea = _idea(
        difficulty: 'Moyen',
        skillTags: const ['marketing_digital', 'vente_negociation', 'relation_client', 'creation_contenu'],
      );
      final answers = BusinessMatchAnswers(
        budget: 3000,
        weeklyHours: 15,
        riskLevel: 'Moyen',
        domains: const {},
        skillTags: const {'marketing_digital'},
      );

      final result = matchBusinessIdeas(answers: answers, ideas: [idea]).first;

      // skillScore = 15 * 1/4 = 3.75 -> total = 25 + 20 + 20 + 10 + 3.75
      expect(result.score, closeTo(78.75, 1e-9));
    });

    test('recoupement total -> score maximal (15)', () {
      final idea = _idea(
        difficulty: 'Moyen',
        skillTags: const ['marketing_digital', 'vente_negociation'],
      );
      final answers = BusinessMatchAnswers(
        budget: 3000,
        weeklyHours: 15,
        riskLevel: 'Moyen',
        domains: const {},
        skillTags: const {'marketing_digital', 'vente_negociation'},
      );

      final result = matchBusinessIdeas(answers: answers, ideas: [idea]).first;

      // skillScore = 15 * 2/2 = 15 -> total = 25 + 20 + 20 + 10 + 15
      expect(result.score, closeTo(90, 1e-9));
    });
  });

  group('matchBusinessIdeas - bout en bout', () {
    test('trie par score décroissant et fournit des raisons pour le meilleur résultat', () {
      final ideas = [
        _idea(
          id: 'best',
          category: 'E-commerce',
          difficulty: 'Facile',
          investmentMin: 200,
          investmentMax: 3000,
          weeklyTimeMin: 10,
          weeklyTimeMax: 25,
          skillTags: const ['marketing_digital', 'vente_negociation'],
        ),
        _idea(
          id: 'medium',
          category: 'Immobilier',
          difficulty: 'Moyen',
          investmentMin: 5000,
          investmentMax: 20000,
          weeklyTimeMin: 20,
          weeklyTimeMax: 40,
          skillTags: const ['gestion_administrative'],
        ),
        _idea(
          id: 'worst',
          category: 'Tech / SaaS',
          difficulty: 'Difficile',
          investmentMin: 10000,
          investmentMax: 50000,
          weeklyTimeMin: 40,
          weeklyTimeMax: 60,
          skillTags: const ['competence_technique'],
        ),
      ];

      final answers = BusinessMatchAnswers(
        budget: 1250,
        weeklyHours: 10,
        riskLevel: 'Facile',
        domains: const {'E-commerce'},
        skillTags: const {'marketing_digital'},
      );

      final results = matchBusinessIdeas(answers: answers, ideas: ideas);

      expect(results, hasLength(3));
      expect(results.first.idea.id, 'best');
      for (var i = 0; i < results.length - 1; i++) {
        expect(results[i].score, greaterThanOrEqualTo(results[i + 1].score));
      }
      expect(results.first.reasons, isNotEmpty);
    });
  });
}
