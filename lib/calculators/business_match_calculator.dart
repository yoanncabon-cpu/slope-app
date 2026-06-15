import '../models/business_idea.dart';

/// Ordre des niveaux de difficulté, du moins au plus exigeant.
const _difficultyOrder = ['Facile', 'Moyen', 'Difficile'];

/// Vocabulaire contrôlé des tags de compétences, avec leur libellé français.
const Map<String, String> skillTagLabels = {
  'marketing_digital': 'Marketing digital & réseaux sociaux',
  'vente_negociation': 'Vente, négociation & prospection',
  'relation_client': 'Relation client & service',
  'creation_contenu': 'Créativité & création de contenu',
  'competence_technique': 'Compétences techniques / développement',
  'organisation_logistique': 'Organisation & logistique',
  'gestion_administrative': 'Gestion administrative & réglementaire',
  'expertise_metier': 'Expertise / savoir-faire dans un domaine précis',
};

/// Réponses de l'utilisateur au quiz "Quel projet pour moi ?".
class BusinessMatchAnswers {
  /// Budget de départ disponible (point médian de la tranche choisie), en €.
  final double budget;

  /// Temps disponible par semaine (point médian de la tranche choisie), en heures.
  final double weeklyHours;

  /// Niveau de risque/complexité accepté : 'Facile' | 'Moyen' | 'Difficile'.
  final String riskLevel;

  /// Catégories d'idées qui intéressent l'utilisateur (vide = pas de préférence).
  final Set<String> domains;

  /// Tags de compétences/appétences sélectionnés (vide = pas de préférence).
  final Set<String> skillTags;

  const BusinessMatchAnswers({
    required this.budget,
    required this.weeklyHours,
    required this.riskLevel,
    required this.domains,
    required this.skillTags,
  });
}

/// Résultat de matching d'une idée business pour un profil donné.
class BusinessMatchResult {
  final BusinessIdea idea;

  /// Score de compatibilité, de 0 à 100.
  final double score;

  /// Raisons courtes expliquant la compatibilité, pour affichage dans l'UI.
  final List<String> reasons;

  const BusinessMatchResult({
    required this.idea,
    required this.score,
    required this.reasons,
  });
}

/// Calcule un score de compatibilité (0-100) entre [answers] et chaque idée
/// de [ideas], et renvoie les résultats triés du meilleur au moins bon.
List<BusinessMatchResult> matchBusinessIdeas({
  required BusinessMatchAnswers answers,
  required List<BusinessIdea> ideas,
}) {
  final results = ideas.map((idea) {
    final reasons = <String>[];

    final budgetScore = _rangeScore(
      answers.budget,
      idea.investmentMin.toDouble(),
      idea.investmentMax.toDouble(),
      25,
    );
    if (budgetScore >= 20) {
      reasons.add('Budget compatible avec votre enveloppe de départ');
    }

    final timeScore = _rangeScore(
      answers.weeklyHours,
      idea.weeklyTimeMin.toDouble(),
      idea.weeklyTimeMax.toDouble(),
      20,
    );
    if (timeScore >= 16) {
      reasons.add('Temps requis adapté à votre disponibilité hebdomadaire');
    }

    final riskScore = _riskScore(answers.riskLevel, idea.difficulty);
    if (riskScore >= 20) {
      reasons.add('Niveau de difficulté en phase avec votre tolérance au risque');
    }

    double domainScore;
    if (answers.domains.isEmpty) {
      domainScore = 10;
    } else if (answers.domains.contains(idea.category)) {
      domainScore = 20;
      reasons.add('Catégorie qui correspond à vos centres d\'intérêt');
    } else {
      domainScore = 0;
    }

    double skillScore;
    if (answers.skillTags.isEmpty) {
      skillScore = 7.5;
    } else if (idea.skillTags.isEmpty) {
      skillScore = 0;
    } else {
      final overlap = answers.skillTags.intersection(idea.skillTags.toSet());
      skillScore = (15 * overlap.length / idea.skillTags.length).clamp(0, 15).toDouble();
      if (overlap.isNotEmpty) {
        final label = skillTagLabels[overlap.first] ?? overlap.first;
        reasons.add('Compétences recherchées : $label');
      }
    }

    if (reasons.isEmpty) {
      reasons.add('Meilleur compromis global parmi vos critères');
    }

    return BusinessMatchResult(
      idea: idea,
      score: budgetScore + timeScore + riskScore + domainScore + skillScore,
      reasons: reasons,
    );
  }).toList();

  results.sort((a, b) => b.score.compareTo(a.score));
  return results;
}

/// Score sur [maxPoints] selon la position de [value] par rapport à
/// l'intervalle [min, max] : score maximal si dans l'intervalle, décroissant
/// proportionnellement à l'écart relatif sinon.
double _rangeScore(double value, double min, double max, double maxPoints) {
  if (value >= min && value <= max) return maxPoints;
  final bound = value < min ? min : max;
  if (bound <= 0) return 0;
  final ratio = (value - bound).abs() / bound;
  return (maxPoints * (1 - ratio)).clamp(0, maxPoints).toDouble();
}

/// Score sur 20 selon la distance entre le niveau de risque choisi et la
/// difficulté de l'idée, dans l'ordre Facile/Moyen/Difficile.
double _riskScore(String chosen, String ideaDifficulty) {
  final chosenIndex = _difficultyOrder.indexOf(chosen);
  final ideaIndex = _difficultyOrder.indexOf(ideaDifficulty);
  if (chosenIndex == -1 || ideaIndex == -1) return 0;
  final distance = (chosenIndex - ideaIndex).abs();
  return (20 - distance * 10).clamp(0, 20).toDouble();
}
