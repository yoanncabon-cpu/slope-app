import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';

import '../theme/app_colors.dart';

/// Dialogue de célébration affiché quand toutes les leçons d'un module
/// viennent d'être marquées comme terminées.
class ModuleCompletedDialog extends StatefulWidget {
  final String moduleTitle;

  const ModuleCompletedDialog({super.key, required this.moduleTitle});

  @override
  State<ModuleCompletedDialog> createState() => _ModuleCompletedDialogState();
}

class _ModuleCompletedDialogState extends State<ModuleCompletedDialog> {
  late final ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(milliseconds: 1200));
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      clipBehavior: Clip.none,
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: Lottie.asset('assets/lottie/quiz_success.json', repeat: false),
                ),
                const SizedBox(height: 8),
                Text(
                  'Module terminé !',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                )
                    .animate()
                    .scale(begin: const Offset(0.6, 0.6), curve: Curves.easeOutBack, duration: 450.ms)
                    .fadeIn(),
                const SizedBox(height: 8),
                Text(
                  'Bravo, vous avez terminé toutes les leçons de « ${widget.moduleTitle} ».',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Continuer'),
                  ),
                ),
              ],
            ),
          ),
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
}
