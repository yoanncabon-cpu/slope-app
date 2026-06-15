import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../widgets/animations/animations.dart';
import '../../widgets/illustration_banner.dart';
import 'breakeven_calculator_screen.dart';
import 'budget_calculator_screen.dart';
import 'compound_interest_screen.dart';
import 'loan_calculator_screen.dart';
import 'portfolio_simulation_screen.dart';
import 'rental_yield_screen.dart';

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tools = <_ToolItem>[
      _ToolItem(
        title: 'Intérêts composés',
        subtitle: 'Projetez la croissance de votre épargne investie',
        icon: Icons.show_chart,
        colorKey: 'actions',
        builder: (_) => const CompoundInterestScreen(),
      ),
      _ToolItem(
        title: 'Capacité d\'emprunt',
        subtitle: 'Calculez la mensualité et le coût d\'un crédit',
        icon: Icons.account_balance,
        colorKey: 'obligations',
        builder: (_) => const LoanCalculatorScreen(),
      ),
      _ToolItem(
        title: 'Rendement locatif',
        subtitle: 'Estimez le rendement brut et net d\'un bien',
        icon: Icons.home_work,
        colorKey: 'immobilier',
        builder: (_) => const RentalYieldScreen(),
      ),
      _ToolItem(
        title: 'Seuil de rentabilité',
        subtitle: 'Déterminez le chiffre d\'affaires à atteindre',
        icon: Icons.balance,
        colorKey: 'gestion',
        builder: (_) => const BreakevenCalculatorScreen(),
      ),
      _ToolItem(
        title: 'Règle 50/30/20',
        subtitle: 'Répartissez votre budget mensuel intelligemment',
        icon: Icons.pie_chart,
        colorKey: 'epargne',
        builder: (_) => const BudgetCalculatorScreen(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Outils')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
        children: [
          const IllustrationBanner(asset: 'assets/images/illustration_tools.svg'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const StaggerFadeSlide(index: 0, child: _FeaturedSimulationCard()),
                const SizedBox(height: 20),
                Text(
                  'Simulateurs financiers',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  'Mettez en pratique ce que vous apprenez avec ces calculatrices.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                      ),
                ),
                const SizedBox(height: 16),
                for (final entry in tools.asMap().entries)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: StaggerFadeSlide(index: entry.key + 1, child: _ToolCard(item: entry.value)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final String colorKey;
  final WidgetBuilder builder;

  _ToolItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.colorKey,
    required this.builder,
  });
}

class _FeaturedSimulationCard extends StatelessWidget {
  const _FeaturedSimulationCard();

  @override
  Widget build(BuildContext context) {
    return TapTilt(
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.secondary],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PortfolioSimulationScreen()),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.auto_graph, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Simulateur de portefeuille',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Testez une allocation et visualisez son évolution simulée',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.white),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  final _ToolItem item;

  const _ToolCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.categoryColor(item.colorKey);
    return TapTilt(
      child: Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: item.builder)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(item.icon, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
