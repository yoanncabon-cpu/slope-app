import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../models/quiz_question.dart';
import '../../providers/content_provider.dart';
import '../../providers/progress_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/animations/animations.dart';

class QuizScreen extends StatefulWidget {
  final String moduleId;

  const QuizScreen({super.key, required this.moduleId});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentIndex = 0;
  int? _selectedOption;
  bool _answered = false;
  int _score = 0;
  bool _finished = false;
  late final ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(milliseconds: 1200));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _selectOption(List<QuizQuestion> questions, int optionIndex) {
    if (_answered) return;
    setState(() {
      _selectedOption = optionIndex;
      _answered = true;
      if (optionIndex == questions[_currentIndex].correctIndex) {
        _score++;
      }
    });
  }

  void _next(List<QuizQuestion> questions) {
    if (_currentIndex == questions.length - 1) {
      final percent = ((_score / questions.length) * 100).round();
      context.read<ProgressProvider>().recordQuizScore(widget.moduleId, percent);
      setState(() => _finished = true);
      if (percent >= 60) {
        _confettiController.play();
      }
      return;
    }
    setState(() {
      _currentIndex++;
      _selectedOption = null;
      _answered = false;
    });
  }

  void _restart() {
    setState(() {
      _currentIndex = 0;
      _selectedOption = null;
      _answered = false;
      _score = 0;
      _finished = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final content = context.watch<ContentProvider>();
    final module = content.findModule(widget.moduleId);

    if (module == null || module.quiz.isEmpty) {
      return const Scaffold(body: Center(child: Text('Quiz indisponible')));
    }

    final questions = module.quiz;

    if (_finished) {
      final percent = ((_score / questions.length) * 100).round();
      final success = percent >= 60;
      return Scaffold(
        appBar: AppBar(title: const Text('Résultat du quiz')),
        body: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    success
                        ? SizedBox(
                            width: 140,
                            height: 140,
                            child: Lottie.asset(
                              'assets/lottie/quiz_success.json',
                              repeat: false,
                            ),
                          )
                        : Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              color: AppColors.warning.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.refresh,
                              size: 48,
                              color: AppColors.warning,
                            ),
                          ).animate().scale(
                              begin: const Offset(0.6, 0.6),
                              curve: Curves.easeOutBack,
                              duration: 450.ms,
                            ).fadeIn(),
                    const SizedBox(height: 20),
                    AnimatedCount(
                      value: percent.toDouble(),
                      formatter: (v) => '${v.round()} %',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$_score bonnes réponses sur ${questions.length}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      success
                          ? 'Bravo, vous maîtrisez bien ce module !'
                          : 'Continuez à réviser, vous progressez.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                          ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _restart,
                        icon: const Icon(Icons.replay),
                        label: const Text('Refaire le quiz'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Retour au module'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (success)
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  shouldLoop: false,
                  numberOfParticles: 22,
                  maxBlastForce: 12,
                  minBlastForce: 4,
                  gravity: 0.25,
                  colors: const [AppColors.primary, AppColors.secondary, AppColors.success, AppColors.accent],
                ),
              ),
          ],
        ),
      );
    }

    final question = questions[_currentIndex];

    return Scaffold(
      appBar: AppBar(title: Text('Quiz · ${_currentIndex + 1}/${questions.length}')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: LinearProgressIndicator(
                value: (_currentIndex + (_answered ? 1 : 0)) / questions.length,
                minHeight: 6,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              children: [
                Text(question.question, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 20),
                for (int i = 0; i < question.options.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _OptionTile(
                      label: question.options[i],
                      state: _optionState(question, i),
                      onTap: () => _selectOption(questions, i),
                    ),
                  ),
                if (_answered) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline, color: AppColors.info),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            question.explanation,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _answered ? () => _next(questions) : null,
                  child: Text(
                    _currentIndex == questions.length - 1 ? 'Voir le résultat' : 'Question suivante',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _OptionState _optionState(QuizQuestion question, int index) {
    if (!_answered) {
      return _OptionState.neutral;
    }
    if (index == question.correctIndex) {
      return _OptionState.correct;
    }
    if (index == _selectedOption) {
      return _OptionState.incorrect;
    }
    return _OptionState.disabled;
  }
}

enum _OptionState { neutral, correct, incorrect, disabled }

class _OptionTile extends StatelessWidget {
  final String label;
  final _OptionState state;
  final VoidCallback onTap;

  const _OptionTile({required this.label, required this.state, required this.onTap});

  @override
  Widget build(BuildContext context) {
    Color borderColor;
    Color? backgroundColor;
    Widget? trailing;

    switch (state) {
      case _OptionState.neutral:
        borderColor = Theme.of(context).colorScheme.outline.withValues(alpha: 0.4);
        break;
      case _OptionState.correct:
        borderColor = AppColors.success;
        backgroundColor = AppColors.success.withValues(alpha: 0.10);
        trailing = const Icon(Icons.check_circle, color: AppColors.success)
            .animate()
            .scale(begin: const Offset(0.5, 0.5), curve: Curves.easeOutBack);
        break;
      case _OptionState.incorrect:
        borderColor = AppColors.danger;
        backgroundColor = AppColors.danger.withValues(alpha: 0.10);
        trailing = const Icon(Icons.cancel, color: AppColors.danger)
            .animate()
            .scale(begin: const Offset(0.5, 0.5), curve: Curves.easeOutBack);
        break;
      case _OptionState.disabled:
        borderColor = Theme.of(context).colorScheme.outline.withValues(alpha: 0.2);
        break;
    }

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
            ?trailing,
          ],
        ),
      ),
    );
  }
}
