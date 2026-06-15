import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/content_provider.dart';
import '../../providers/progress_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/animations/animations.dart';

class LessonScreen extends StatelessWidget {
  final String moduleId;
  final String lessonId;

  const LessonScreen({super.key, required this.moduleId, required this.lessonId});

  @override
  Widget build(BuildContext context) {
    final content = context.watch<ContentProvider>();
    final progress = context.watch<ProgressProvider>();
    final module = content.findModule(moduleId);

    if (module == null) {
      return const Scaffold(body: Center(child: Text('Module introuvable')));
    }

    final lesson = module.lessons.firstWhere(
      (l) => l.id == lessonId,
      orElse: () => module.lessons.first,
    );
    final index = module.lessons.indexWhere((l) => l.id == lessonId);
    final isCompleted = progress.isLessonCompleted(lesson.id);
    final color = AppColors.categoryColor(module.colorKey);

    final paragraphs = lesson.content
        .split('\n')
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(module.title),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: AnimatedProgressBar(
            value: (index + 1) / module.lessons.length,
            minHeight: 4,
            borderRadius: BorderRadius.zero,
            color: color,
            backgroundColor: color.withValues(alpha: 0.12),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              children: [
                StaggerFadeSlide(
                  index: 0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              'Leçon ${index + 1} / ${module.lessons.length}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: color,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Icon(Icons.schedule, size: 16, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
                          const SizedBox(width: 4),
                          Text(
                            '${lesson.durationMinutes} min',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(lesson.title, style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                for (final entry in paragraphs.asMap().entries) ...[
                  StaggerFadeSlide(
                    index: entry.key + 1,
                    child: Text(
                      entry.value,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: TapTilt(
                child: SizedBox(
                  width: double.infinity,
                  child: isCompleted
                      ? OutlinedButton.icon(
                          onPressed: () => progress.setLessonCompleted(lesson.id, false),
                          icon: const Icon(Icons.check_circle, color: AppColors.success),
                          label: const Text('Leçon terminée'),
                        )
                      : ElevatedButton.icon(
                          onPressed: () => progress.setLessonCompleted(lesson.id, true),
                          icon: const Icon(Icons.check),
                          label: const Text('Marquer comme terminée'),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
