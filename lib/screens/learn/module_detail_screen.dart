import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/content_provider.dart';
import '../../providers/progress_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/icon_mapper.dart';
import 'lesson_screen.dart';
import 'quiz_screen.dart';

class ModuleDetailScreen extends StatelessWidget {
  final String moduleId;

  const ModuleDetailScreen({super.key, required this.moduleId});

  @override
  Widget build(BuildContext context) {
    final content = context.watch<ContentProvider>();
    final progress = context.watch<ProgressProvider>();
    final module = content.findModule(moduleId);

    if (module == null) {
      return const Scaffold(body: Center(child: Text('Module introuvable')));
    }

    final color = AppColors.categoryColor(module.colorKey);
    final quizScore = progress.quizScore(module.id);

    return Scaffold(
      appBar: AppBar(title: Text(module.title)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(mapIcon(module.icon), color: color, size: 26),
                ),
                const SizedBox(height: 14),
                Text(module.summary, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Icon(Icons.signal_cellular_alt, size: 16, color: color),
                    const SizedBox(width: 6),
                    Text(module.level, style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(width: 16),
                    Icon(Icons.schedule, size: 16, color: color),
                    const SizedBox(width: 6),
                    Text('${module.durationMinutes} min', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Leçons', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          ...module.lessons.asMap().entries.map((entry) {
            final i = entry.key;
            final lesson = entry.value;
            final done = progress.isLessonCompleted(lesson.id);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  leading: CircleAvatar(
                    backgroundColor: done
                        ? AppColors.success.withValues(alpha: 0.15)
                        : color.withValues(alpha: 0.12),
                    child: done
                        ? const Icon(Icons.check, color: AppColors.success)
                        : Text('${i + 1}', style: TextStyle(color: color, fontWeight: FontWeight.w700)),
                  ),
                  title: Text(lesson.title),
                  subtitle: Text('${lesson.durationMinutes} min de lecture'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LessonScreen(moduleId: module.id, lessonId: lesson.id),
                    ),
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 12),
          Card(
            color: color.withValues(alpha: 0.08),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              leading: CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.15),
                child: Icon(Icons.quiz, color: color),
              ),
              title: const Text('Quiz du module'),
              subtitle: Text(
                quizScore != null
                    ? 'Meilleur score : $quizScore %'
                    : '${module.quiz.length} questions',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => QuizScreen(moduleId: module.id)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
