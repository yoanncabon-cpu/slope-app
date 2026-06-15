import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../calculators/business_match_calculator.dart';
import '../../models/business_idea.dart';
import '../../providers/content_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/icon_mapper.dart';
import '../../widgets/animations/animations.dart';
import 'business_idea_detail_screen.dart';

class _Choice<T> {
  final String label;
  final T value;

  const _Choice(this.label, this.value);
}

const _budgetOptions = [
  _Choice('Moins de 500 €', 250.0),
  _Choice('500 € – 2 000 €', 1250.0),
  _Choice('2 000 € – 10 000 €', 6000.0),
  _Choice('Plus de 10 000 €', 15000.0),
];

const _timeOptions = [
  _Choice('Moins de 5h', 3.0),
  _Choice('5h - 15h', 10.0),
  _Choice('15h - 30h', 22.0),
  _Choice('30h ou plus', 40.0),
];

const _riskOptions = [
  _Choice('Je préfère un projet simple, avec peu de risque', 'Facile'),
  _Choice('Je suis prêt à prendre des risques modérés', 'Moyen'),
  _Choice('Je veux relever un défi ambitieux, même risqué', 'Difficile'),
];

/// Quiz "Quel projet pour moi ?" : 5 questions sur le profil de
/// l'utilisateur, puis un top 3 d'idées business calculé via
/// [matchBusinessIdeas].
class BusinessMatchQuizScreen extends StatefulWidget {
  const BusinessMatchQuizScreen({super.key});

  @override
  State<BusinessMatchQuizScreen> createState() => _BusinessMatchQuizScreenState();
}

class _BusinessMatchQuizScreenState extends State<BusinessMatchQuizScreen> {
  static const int _questionCount = 5;

  int _currentIndex = 0;
  bool _finished = false;

  double? _budget;
  double? _weeklyHours;
  String? _riskLevel;
  final Set<String> _domains = {};
  final Set<String> _skillTags = {};

  bool get _canProceed {
    switch (_currentIndex) {
      case 0:
        return _budget != null;
      case 1:
        return _weeklyHours != null;
      case 2:
        return _riskLevel != null;
      default:
        return true;
    }
  }

  void _next() {
    if (_currentIndex == _questionCount - 1) {
      setState(() => _finished = true);
      return;
    }
    setState(() => _currentIndex++);
  }

  void _previous() {
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
    }
  }

  void _restart() {
    setState(() {
      _currentIndex = 0;
      _finished = false;
      _budget = null;
      _weeklyHours = null;
      _riskLevel = null;
      _domains.clear();
      _skillTags.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final content = context.watch<ContentProvider>();

    if (_finished) {
      return _ResultsView(
        answers: BusinessMatchAnswers(
          budget: _budget!,
          weeklyHours: _weeklyHours!,
          riskLevel: _riskLevel!,
          domains: _domains,
          skillTags: _skillTags,
        ),
        ideas: content.businessIdeas,
        onRestart: _restart,
      );
    }

    final categories = {for (final idea in content.businessIdeas) idea.category}.toList()..sort();

    return Scaffold(
      appBar: AppBar(
        title: Text('Quel projet pour moi ? · ${_currentIndex + 1}/$_questionCount'),
        leading: _currentIndex > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                tooltip: 'Question précédente',
                onPressed: _previous,
              )
            : null,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: LinearProgressIndicator(
                value: (_currentIndex + 1) / _questionCount,
                minHeight: 6,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              children: [_buildQuestion(context, categories)],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _canProceed ? _next : null,
                  child: Text(_currentIndex == _questionCount - 1 ? 'Voir mes résultats' : 'Suivant'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestion(BuildContext context, List<String> categories) {
    switch (_currentIndex) {
      case 0:
        return _SingleChoiceQuestion<double>(
          title: 'Quel budget de départ pouvez-vous investir ?',
          options: _budgetOptions,
          value: _budget,
          onChanged: (v) => setState(() => _budget = v),
        );
      case 1:
        return _SingleChoiceQuestion<double>(
          title: 'Combien de temps pouvez-vous y consacrer par semaine ?',
          options: _timeOptions,
          value: _weeklyHours,
          onChanged: (v) => setState(() => _weeklyHours = v),
        );
      case 2:
        return _SingleChoiceQuestion<String>(
          title: 'Quel niveau de risque/complexité êtes-vous prêt à affronter ?',
          options: _riskOptions,
          value: _riskLevel,
          onChanged: (v) => setState(() => _riskLevel = v),
        );
      case 3:
        return _MultiChoiceQuestion(
          title: 'Quels domaines vous intéressent ?',
          subtitle: 'Jusqu\'à 3 choix, ou « Peu importe » pour ne pas filtrer.',
          options: categories,
          selected: _domains,
          maxSelections: 3,
          onChanged: (next) => setState(() {
            _domains.clear();
            _domains.addAll(next);
          }),
        );
      case 4:
        return _MultiChoiceQuestion(
          title: 'Quelles sont vos compétences ou appétences ?',
          subtitle: 'Jusqu\'à 4 choix, ou « Peu importe » pour ne pas filtrer.',
          options: skillTagLabels.keys.toList(),
          optionLabels: skillTagLabels,
          selected: _skillTags,
          maxSelections: 4,
          onChanged: (next) => setState(() {
            _skillTags.clear();
            _skillTags.addAll(next);
          }),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class _SingleChoiceQuestion<T> extends StatelessWidget {
  final String title;
  final List<_Choice<T>> options;
  final T? value;
  final ValueChanged<T> onChanged;

  const _SingleChoiceQuestion({
    required this.title,
    required this.options,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 20),
        for (final option in options)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _OptionTile(
              label: option.label,
              selected: value == option.value,
              onTap: () => onChanged(option.value),
            ),
          ),
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _OptionTile({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final borderColor =
        selected ? AppColors.primary : Theme.of(context).colorScheme.outline.withValues(alpha: 0.4);
    final backgroundColor = selected ? AppColors.primary.withValues(alpha: 0.08) : null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: 1.5),
          borderRadius: BorderRadius.circular(14),
          color: backgroundColor,
        ),
        child: Row(
          children: [
            Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyLarge)),
            if (selected) const Icon(Icons.check_circle, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}

class _MultiChoiceQuestion extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<String> options;
  final Map<String, String>? optionLabels;
  final Set<String> selected;
  final int maxSelections;
  final ValueChanged<Set<String>> onChanged;

  const _MultiChoiceQuestion({
    required this.title,
    required this.subtitle,
    required this.options,
    this.optionLabels,
    required this.selected,
    required this.maxSelections,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
              ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: const Text('Peu importe'),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              selected: selected.isEmpty,
              onSelected: (_) => onChanged(const {}),
            ),
            for (final option in options)
              ChoiceChip(
                label: Text(optionLabels?[option] ?? option),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                selected: selected.contains(option),
                onSelected: (isSelected) {
                  final next = Set<String>.from(selected);
                  if (isSelected) {
                    if (next.length < maxSelections) {
                      next.add(option);
                    }
                  } else {
                    next.remove(option);
                  }
                  onChanged(next);
                },
              ),
          ],
        ),
      ],
    );
  }
}

class _ResultsView extends StatelessWidget {
  final BusinessMatchAnswers answers;
  final List<BusinessIdea> ideas;
  final VoidCallback onRestart;

  const _ResultsView({required this.answers, required this.ideas, required this.onRestart});

  @override
  Widget build(BuildContext context) {
    final results = matchBusinessIdeas(answers: answers, ideas: ideas).take(3).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Vos recommandations')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        children: [
          Text(
            'Top 3 des idées qui correspondent à votre profil',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(
            'Basé sur votre budget, votre disponibilité, votre tolérance au risque et vos centres d\'intérêt.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                ),
          ),
          const SizedBox(height: 20),
          for (final entry in results.asMap().entries)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: StaggerFadeSlide(index: entry.key, child: _ResultCard(result: entry.value)),
            ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onRestart,
              icon: const Icon(Icons.replay),
              label: const Text('Refaire le test'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final BusinessMatchResult result;

  const _ResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final idea = result.idea;
    final color = AppColors.categoryColor('idee');

    return TapTilt(
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => BusinessIdeaDetailScreen(ideaId: idea.id)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(mapIcon(idea.icon), color: color, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            idea.category.toUpperCase(),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: color,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                  fontSize: 11,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(idea.title, style: Theme.of(context).textTheme.titleMedium),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        AnimatedCount(
                          value: result.score,
                          formatter: (v) => '${v.round()}%',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        Text(
                          'compatibilité',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  idea.pitch,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                ),
                const SizedBox(height: 12),
                for (final reason in result.reasons.take(3))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check, size: 16, color: AppColors.success),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(reason, style: Theme.of(context).textTheme.bodySmall),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
