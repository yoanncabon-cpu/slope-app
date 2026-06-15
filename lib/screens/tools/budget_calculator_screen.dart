import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../utils/formatters.dart';
import '../../widgets/animations/animations.dart';
import '../../widgets/calculator_field.dart';
import '../../widgets/illustration_banner.dart';
import '../../widgets/result_tile.dart';

class BudgetCalculatorScreen extends StatefulWidget {
  const BudgetCalculatorScreen({super.key});

  @override
  State<BudgetCalculatorScreen> createState() => _BudgetCalculatorScreenState();
}

class _BudgetCalculatorScreenState extends State<BudgetCalculatorScreen> {
  final _incomeController = TextEditingController(text: '2500');

  @override
  void dispose() {
    _incomeController.dispose();
    super.dispose();
  }

  double _parse(TextEditingController controller) {
    return double.tryParse(controller.text.replaceAll(',', '.')) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final income = _parse(_incomeController);
    final needs = income * 0.5;
    final wants = income * 0.3;
    final savings = income * 0.2;

    return Scaffold(
      appBar: AppBar(title: const Text('Règle 50/30/20')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        children: [
          const IllustrationBanner(
            asset: 'assets/images/illustration_tools.svg',
            horizontalPadding: 0,
          ),
          Text(
            'La règle du 50/30/20 répartit votre revenu net mensuel entre besoins essentiels, envies et épargne/investissement.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                ),
          ),
          const SizedBox(height: 20),
          CalculatorField(label: 'Revenu mensuel net', controller: _incomeController, suffixText: '€', onChanged: (_) => setState(() {})),
          const SizedBox(height: 8),
          if (income > 0) ...[
            StaggerFadeSlide(
              index: 0,
              child: SizedBox(
                height: 180,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 3,
                    centerSpaceRadius: 40,
                    sections: [
                      PieChartSectionData(
                        value: 50,
                        color: AppColors.primary,
                        title: '50%',
                        radius: 60,
                        titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                      PieChartSectionData(
                        value: 30,
                        color: AppColors.accent,
                        title: '30%',
                        radius: 60,
                        titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                      PieChartSectionData(
                        value: 20,
                        color: AppColors.secondary,
                        title: '20%',
                        radius: 60,
                        titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                    ],
                  ),
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOutCubic,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          Text('Répartition mensuelle', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          StaggerFadeSlide(
            index: 1,
            child: Column(
              children: [
                ResultTile(
                  label: 'Besoins essentiels (50 %) — logement, factures, alimentation',
                  value: formatEuro(needs, decimals: true),
                  numericValue: needs,
                  formatter: (v) => formatEuro(v, decimals: true),
                  color: AppColors.primary,
                  highlight: true,
                ),
                ResultTile(
                  label: 'Envies (30 %) — loisirs, sorties, plaisirs',
                  value: formatEuro(wants, decimals: true),
                  numericValue: wants,
                  formatter: (v) => formatEuro(v, decimals: true),
                  color: AppColors.accent,
                  highlight: true,
                ),
                ResultTile(
                  label: 'Épargne & investissement (20 %)',
                  value: formatEuro(savings, decimals: true),
                  numericValue: savings,
                  formatter: (v) => formatEuro(v, decimals: true),
                  color: AppColors.secondary,
                  highlight: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
