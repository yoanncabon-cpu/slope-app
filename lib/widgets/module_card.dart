import 'package:flutter/material.dart';

import '../models/learning_module.dart';
import '../theme/app_colors.dart';
import '../utils/icon_mapper.dart';
import 'animations/animations.dart';

/// Carte représentant un module d'apprentissage, avec sa progression.
class ModuleCard extends StatelessWidget {
  final LearningModule module;
  final double progress;
  final VoidCallback onTap;

  const ModuleCard({
    super.key,
    required this.module,
    required this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.categoryColor(module.colorKey);
    final isDone = progress >= 1.0;

    return TapTilt(
      child: Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(mapIcon(module.icon), color: color, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            module.title,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        if (isDone)
                          Icon(Icons.check_circle, color: AppColors.success, size: 20),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      module.summary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                          ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _Tag(label: module.level),
                        const SizedBox(width: 8),
                        _Tag(label: '${module.durationMinutes} min'),
                        const Spacer(),
                        AnimatedCount(
                          value: progress * 100,
                          formatter: (v) => '${v.round()} %',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: color,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    AnimatedProgressBar(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: color.withValues(alpha: 0.12),
                      color: color,
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

class _Tag extends StatelessWidget {
  final String label;
  const _Tag({required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceAlt : AppColors.lightSurfaceAlt,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
      ),
    );
  }
}
