import 'package:flutter/material.dart';

import '../models/business_idea.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';
import '../utils/icon_mapper.dart';

class IdeaCard extends StatelessWidget {
  final BusinessIdea idea;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;

  const IdeaCard({
    super.key,
    required this.idea,
    required this.isFavorite,
    required this.onTap,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.categoryColor('idee');

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
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
                        Text(
                          idea.title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onToggleFavorite,
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? AppColors.danger : null,
                    ),
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
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _StatChip(
                    icon: Icons.bar_chart,
                    label: idea.difficulty,
                    color: _difficultyColor(idea.difficulty),
                  ),
                  _StatChip(
                    icon: Icons.savings_outlined,
                    label: '${formatEuro(idea.investmentMin)} - ${formatEuro(idea.investmentMax)}',
                  ),
                  _StatChip(
                    icon: Icons.trending_up,
                    label: '+${idea.growthRatePercent.toStringAsFixed(1)} %/an',
                    color: AppColors.success,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _difficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Facile':
        return AppColors.success;
      case 'Difficile':
        return AppColors.danger;
      default:
        return AppColors.warning;
    }
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _StatChip({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = color ?? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceAlt : AppColors.lightSurfaceAlt,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: c),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: c,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
          ),
        ],
      ),
    );
  }
}
