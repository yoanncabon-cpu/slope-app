import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../models/business_idea.dart';
import '../../providers/content_provider.dart';
import '../../providers/progress_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatters.dart';
import '../../utils/icon_mapper.dart';
import '../../widgets/animations/animations.dart';

class BusinessIdeaDetailScreen extends StatelessWidget {
  final String ideaId;

  const BusinessIdeaDetailScreen({super.key, required this.ideaId});

  @override
  Widget build(BuildContext context) {
    final content = context.watch<ContentProvider>();
    final progress = context.watch<ProgressProvider>();
    final idea = content.findBusinessIdea(ideaId);

    if (idea == null) {
      return const Scaffold(body: Center(child: Text('Idée introuvable')));
    }

    final color = AppColors.categoryColor('idee');
    final isFavorite = progress.isFavoriteIdea(idea.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(idea.title),
        actions: [
          IconButton(
            onPressed: () => progress.toggleFavoriteIdea(idea.id),
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? AppColors.danger : null,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(mapIcon(idea.icon), color: color, size: 28),
              ),
              const SizedBox(width: 14),
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
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(idea.pitch, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              StaggerFadeSlide(
                index: 0,
                child: _StatCard(
                  icon: Icons.bar_chart,
                  label: 'Difficulté',
                  value: idea.difficulty,
                  color: _difficultyColor(idea.difficulty),
                ),
              ),
              StaggerFadeSlide(
                index: 1,
                child: _StatCard(
                  icon: Icons.savings_outlined,
                  label: 'Investissement initial',
                  value: '${formatEuro(idea.investmentMin)} - ${formatEuro(idea.investmentMax)}',
                ),
              ),
              StaggerFadeSlide(
                index: 2,
                child: _StatCard(
                  icon: Icons.schedule,
                  label: 'Rentabilité estimée',
                  value: '${idea.timeToProfitMonths} mois',
                ),
              ),
              StaggerFadeSlide(
                index: 3,
                child: _StatCard(
                  icon: Icons.trending_up,
                  label: 'Croissance annuelle',
                  value: '+${idea.growthRatePercent.toStringAsFixed(1)} %',
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Description', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            idea.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
          ),
          const SizedBox(height: 24),
          Text('Cible', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.groups, color: color),
                const SizedBox(width: 10),
                Expanded(child: Text(idea.targetAudience, style: Theme.of(context).textTheme.bodyMedium)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('${idea.marketSizeLabel} · évolution du marché', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            'En ${idea.marketTrendUnit}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: _MarketTrendChart(idea: idea, color: color),
          ).animate().fadeIn(duration: 450.ms, delay: 100.ms).slideY(begin: 0.08, end: 0, curve: Curves.easeOutCubic),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: StaggerFadeSlide(
                  index: 4,
                  child: _ProsConsCard(title: 'Avantages', items: idea.pros, color: AppColors.success, icon: Icons.add_circle_outline),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StaggerFadeSlide(
                  index: 5,
                  child: _ProsConsCard(title: 'Limites', items: idea.cons, color: AppColors.danger, icon: Icons.remove_circle_outline),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Premiers pas', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          ...idea.firstSteps.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${entry.key + 1}',
                      style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(entry.value, style: Theme.of(context).textTheme.bodyMedium),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 24),
          Text('Compétences utiles', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: idea.skillsNeeded
                .map((skill) => Chip(label: Text(skill)))
                .toList(),
          ),
        ],
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

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? color;

  const _StatCard({required this.icon, required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.primary;
    return Container(
      width: (MediaQuery.of(context).size.width - 40 - 10) / 2,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: c, size: 20),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
          ),
          const SizedBox(height: 2),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

class _ProsConsCard extends StatelessWidget {
  final String title;
  final List<String> items;
  final Color color;
  final IconData icon;

  const _ProsConsCard({required this.title, required this.items, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: color)),
          const SizedBox(height: 10),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon, size: 18, color: color),
                    const SizedBox(width: 6),
                    Expanded(child: Text(item, style: Theme.of(context).textTheme.bodySmall)),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _MarketTrendChart extends StatelessWidget {
  final BusinessIdea idea;
  final Color color;

  const _MarketTrendChart({required this.idea, required this.color});

  @override
  Widget build(BuildContext context) {
    final points = idea.marketTrend;
    final spots = points
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.value))
        .toList();

    final values = points.map((p) => p.value).toList();
    final minY = values.reduce((a, b) => a < b ? a : b);
    final maxY = values.reduce((a, b) => a > b ? a : b);
    final padding = (maxY - minY) * 0.2 == 0 ? maxY * 0.1 : (maxY - minY) * 0.2;

    return LineChart(
      LineChartData(
        minY: (minY - padding).clamp(0, double.infinity),
        maxY: maxY + padding,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= points.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '${points[idx].year}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: color,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(show: true, color: color.withValues(alpha: 0.12)),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => color,
            getTooltipItems: (spots) => spots.map((spot) {
              final point = points[spot.x.toInt()];
              return LineTooltipItem(
                '${point.year}\n${formatNumber(point.value)} ${idea.marketTrendUnit}',
                const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              );
            }).toList(),
          ),
        ),
      ),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }
}
