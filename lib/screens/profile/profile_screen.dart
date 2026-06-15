import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/content_provider.dart';
import '../../providers/progress_provider.dart';
import '../../providers/theme_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/animations/animations.dart';
import '../../widgets/illustration_banner.dart';
import 'glossary_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final content = context.watch<ContentProvider>();
    final progress = context.watch<ProgressProvider>();
    final themeProvider = context.watch<AppThemeProvider>();

    final allModules = content.allModules;
    final overall = progress.overallProgress(allModules);
    final completedModules = progress.completedModulesCount(allModules);
    final completedLessons = allModules.fold<int>(
      0,
      (sum, m) => sum + m.lessons.where((l) => progress.isLessonCompleted(l.id)).length,
    );
    final favoritesCount = progress.favoriteIdeas.length;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        children: [
          const IllustrationBanner(
            asset: 'assets/images/illustration_profile.svg',
            horizontalPadding: 0,
          ),
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Votre profil', style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 2),
                    Text(
                      'Continuez sur votre lancée !',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          StaggerFadeSlide(
            index: 0,
            child: Row(
              children: [
                Expanded(
                  child: _StatBlock(
                    icon: Icons.donut_large,
                    label: 'Progression globale',
                    value: '${(overall * 100).round()} %',
                    numericValue: overall * 100,
                    formatter: (v) => '${v.round()} %',
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatBlock(
                    icon: Icons.menu_book,
                    label: 'Modules terminés',
                    value: '$completedModules / ${allModules.length}',
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          StaggerFadeSlide(
            index: 1,
            child: Row(
              children: [
                Expanded(
                  child: _StatBlock(
                    icon: Icons.check_circle_outline,
                    label: 'Leçons terminées',
                    value: '$completedLessons / ${content.totalLessons}',
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatBlock(
                    icon: Icons.favorite,
                    label: 'Idées favorites',
                    value: '$favoritesCount',
                    numericValue: favoritesCount.toDouble(),
                    formatter: (v) => '${v.round()}',
                    color: AppColors.danger,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Text('Apparence', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(value: ThemeMode.light, icon: Icon(Icons.light_mode), label: Text('Clair')),
              ButtonSegment(value: ThemeMode.system, icon: Icon(Icons.brightness_auto), label: Text('Auto')),
              ButtonSegment(value: ThemeMode.dark, icon: Icon(Icons.dark_mode), label: Text('Sombre')),
            ],
            selected: {themeProvider.themeMode},
            onSelectionChanged: (selection) => themeProvider.setThemeMode(selection.first),
          ),
          const SizedBox(height: 28),
          Text('Ressources', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.menu_book_outlined, color: AppColors.info),
              ),
              title: const Text('Glossaire'),
              subtitle: Text('${content.glossary.length} termes expliqués'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GlossaryScreen())),
            ),
          ),
          const SizedBox(height: 28),
          Text('À propos', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Slope', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 6),
                Text(
                  'Slope vous accompagne pour apprendre à investir et entreprendre, '
                  'grâce à des modules pédagogiques, des idées de business avec '
                  'études de marché et des simulateurs financiers.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
                ),
                const SizedBox(height: 10),
                Text(
                  'Version 1.0.0',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBlock extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final double? numericValue;
  final String Function(double value)? formatter;

  const _StatBlock({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.numericValue,
    this.formatter,
  }) : assert(
          numericValue == null || formatter != null,
          'formatter est requis quand numericValue est fourni',
        );

  @override
  Widget build(BuildContext context) {
    final valueStyle = Theme.of(context).textTheme.titleLarge;
    final valueWidget = (numericValue != null && formatter != null)
        ? AnimatedCount(value: numericValue!, formatter: formatter!, style: valueStyle)
        : Text(value, style: valueStyle);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 10),
          valueWidget,
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
          ),
        ],
      ),
    );
  }
}
