import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/learning_module.dart';
import '../../providers/content_provider.dart';
import '../../providers/progress_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/animations/animations.dart';
import '../../widgets/idea_card.dart';
import '../../widgets/illustration_banner.dart';
import '../../widgets/module_card.dart';
import '../../widgets/section_header.dart';
import '../ideas/business_idea_detail_screen.dart';
import '../learn/learn_screen.dart';
import '../learn/module_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final content = context.watch<ContentProvider>();
    final progress = context.watch<ProgressProvider>();

    final allModules = content.allModules;
    final overall = progress.overallProgress(allModules);
    final completedCount = progress.completedModulesCount(allModules);

    final inProgress = allModules.where((m) {
      final p = progress.moduleProgress(m);
      return p > 0 && p < 1;
    }).toList();

    final nextModule = inProgress.isNotEmpty
        ? inProgress.first
        : allModules.firstWhere(
            (m) => progress.moduleProgress(m) < 1,
            orElse: () => allModules.first,
          );

    final ideaOfTheDay = content.businessIdeas.isNotEmpty
        ? content.businessIdeas[DateTime.now().day % content.businessIdeas.length]
        : null;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        children: [
          Text(
            'Bienvenue sur Slope',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Apprenez à investir et entreprendre, un module à la fois.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                ),
          ),
          const IllustrationBanner(
            asset: 'assets/images/illustration_growth.svg',
            height: 160,
            horizontalPadding: 0,
          ),
          StaggerFadeSlide(
            index: 0,
            child: _ProgressCard(
              overall: overall,
              completedCount: completedCount,
              totalCount: allModules.length,
            ),
          ),
          const SizedBox(height: 28),
          SectionHeader(
            title: 'Continuer l\'apprentissage',
            actionLabel: 'Tout voir',
            onAction: () => _openLearn(context),
          ),
          const SizedBox(height: 12),
          StaggerFadeSlide(
            index: 1,
            child: ModuleCard(
              module: nextModule,
              progress: progress.moduleProgress(nextModule),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ModuleDetailScreen(moduleId: nextModule.id)),
              ),
            ),
          ),
          const SizedBox(height: 28),
          Text('Catégories', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          StaggerFadeSlide(
            index: 2,
            child: Row(
              children: [
                Expanded(
                  child: _CategoryCard(
                    title: 'Investissement',
                    subtitle: '${content.investmentModules.length} modules',
                    icon: Icons.trending_up,
                    color: AppColors.categoryColor('actions'),
                    onTap: () => _openLearn(context, track: LearningTrack.investment),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _CategoryCard(
                    title: 'Entrepreneuriat',
                    subtitle: '${content.entrepreneurshipModules.length} modules',
                    icon: Icons.rocket_launch,
                    color: AppColors.categoryColor('idee'),
                    onTap: () => _openLearn(context, track: LearningTrack.entrepreneurship),
                  ),
                ),
              ],
            ),
          ),
          if (ideaOfTheDay != null) ...[
            const SizedBox(height: 28),
            SectionHeader(title: 'Idée business du jour'),
            const SizedBox(height: 12),
            StaggerFadeSlide(
              index: 3,
              child: IdeaCard(
                idea: ideaOfTheDay,
                isFavorite: progress.isFavoriteIdea(ideaOfTheDay.id),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BusinessIdeaDetailScreen(ideaId: ideaOfTheDay.id),
                  ),
                ),
                onToggleFavorite: () => progress.toggleFavoriteIdea(ideaOfTheDay.id),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _openLearn(BuildContext context, {LearningTrack? track}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => LearnScreen(initialTrack: track)),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final double overall;
  final int completedCount;
  final int totalCount;

  const _ProgressCard({
    required this.overall,
    required this.completedCount,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Votre progression',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  '$completedCount sur $totalCount modules terminés',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                ),
                const SizedBox(height: 14),
                AnimatedProgressBar(
                  value: overall,
                  minHeight: 8,
                  backgroundColor: Colors.white.withValues(alpha: 0.25),
                  color: Colors.white,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          AnimatedCount(
            value: overall * 100,
            formatter: (v) => '${v.round()}%',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TapTilt(
      child: Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(height: 12),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
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
