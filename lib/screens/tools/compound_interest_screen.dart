import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../theme/app_colors.dart';
import '../../utils/formatters.dart';
import '../../widgets/calculator_field.dart';
import '../../widgets/result_tile.dart';

class CompoundInterestScreen extends StatefulWidget {
  const CompoundInterestScreen({super.key});

  @override
  State<CompoundInterestScreen> createState() => _CompoundInterestScreenState();
}

class _CompoundInterestScreenState extends State<CompoundInterestScreen> {
  final _initialController = TextEditingController(text: '1000');
  final _monthlyController = TextEditingController(text: '100');
  final _rateController = TextEditingController(text: '5');
  final _yearsController = TextEditingController(text: '15');

  @override
  void dispose() {
    _initialController.dispose();
    _monthlyController.dispose();
    _rateController.dispose();
    _yearsController.dispose();
    super.dispose();
  }

  double _parse(TextEditingController controller) {
    return double.tryParse(controller.text.replaceAll(',', '.')) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final initial = _parse(_initialController);
    final monthly = _parse(_monthlyController);
    final rate = _parse(_rateController);
    final years = _parse(_yearsController).clamp(1, 60).toInt();

    final monthlyRate = rate / 100 / 12;
    final yearlyData = <_YearData>[];
    double balance = initial;
    double invested = initial;

    for (int year = 1; year <= years; year++) {
      for (int month = 0; month < 12; month++) {
        balance = balance * (1 + monthlyRate) + monthly;
        invested += monthly;
      }
      yearlyData.add(_YearData(year: year, invested: invested, balance: balance));
    }

    final finalBalance = yearlyData.isNotEmpty ? yearlyData.last.balance : initial;
    final totalInvested = yearlyData.isNotEmpty ? yearlyData.last.invested : initial;
    final interestEarned = finalBalance - totalInvested;
    final color = AppColors.categoryColor('actions');

    return Scaffold(
      appBar: AppBar(title: const Text('Intérêts composés')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          Text(
            'Estimez la valeur future de votre épargne en tenant compte des intérêts composés et de vos versements réguliers.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                ),
          ),
          const SizedBox(height: 20),
          CalculatorField(label: 'Capital initial', controller: _initialController, suffixText: '€', onChanged: (_) => setState(() {})),
          CalculatorField(label: 'Versement mensuel', controller: _monthlyController, suffixText: '€', onChanged: (_) => setState(() {})),
          CalculatorField(label: 'Rendement annuel estimé', controller: _rateController, suffixText: '%', onChanged: (_) => setState(() {})),
          CalculatorField(label: 'Durée', controller: _yearsController, suffixText: 'années', onChanged: (_) => setState(() {})),
          const SizedBox(height: 8),
          Text('Résultat', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          ResultTile(
            label: 'Capital final',
            value: formatEuro(finalBalance),
            numericValue: finalBalance,
            formatter: formatEuro,
            color: color,
            highlight: true,
          ),
          ResultTile(
            label: 'Total versé',
            value: formatEuro(totalInvested),
            numericValue: totalInvested,
            formatter: formatEuro,
          ),
          ResultTile(
            label: 'Intérêts générés',
            value: formatEuro(interestEarned),
            numericValue: interestEarned,
            formatter: formatEuro,
            color: AppColors.success,
          ),
          const SizedBox(height: 16),
          Text('Évolution annuelle', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: yearlyData.isEmpty
                ? const SizedBox.shrink()
                : BarChart(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutCubic,
                    BarChartData(
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: years > 10 ? (years / 5).ceilToDouble() : 1,
                            getTitlesWidget: (value, meta) {
                              final idx = value.toInt();
                              if (idx < 1 || idx > yearlyData.length) return const SizedBox.shrink();
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text('$idx', style: Theme.of(context).textTheme.bodySmall),
                              );
                            },
                          ),
                        ),
                      ),
                      barGroups: yearlyData.map((data) {
                        return BarChartGroupData(
                          x: data.year,
                          barRods: [
                            BarChartRodData(
                              toY: data.balance,
                              width: years > 20 ? 4 : 10,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                              rodStackItems: [
                                BarChartRodStackItem(0, data.invested.clamp(0, data.balance), Theme.of(context).colorScheme.outline.withValues(alpha: 0.3)),
                                BarChartRodStackItem(data.invested.clamp(0, data.balance), data.balance, color),
                              ],
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
          ).animate().fadeIn(duration: 450.ms).slideY(begin: 0.08, end: 0, curve: Curves.easeOutCubic),
          const SizedBox(height: 12),
          Row(
            children: [
              _Legend(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3), label: 'Versements'),
              const SizedBox(width: 16),
              _Legend(color: color, label: 'Intérêts'),
            ],
          ),
        ],
      ),
    );
  }
}

class _YearData {
  final int year;
  final double invested;
  final double balance;

  _YearData({required this.year, required this.invested, required this.balance});
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;

  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
