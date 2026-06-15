import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../models/simulation_asset_class.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatters.dart';
import '../../widgets/calculator_field.dart';
import '../../widgets/result_tile.dart';

class PortfolioSimulationScreen extends StatefulWidget {
  const PortfolioSimulationScreen({super.key});

  @override
  State<PortfolioSimulationScreen> createState() => _PortfolioSimulationScreenState();
}

class _PortfolioSimulationScreenState extends State<PortfolioSimulationScreen> {
  final _initialController = TextEditingController(text: '10000');
  final _monthlyController = TextEditingController(text: '100');
  final _yearsController = TextEditingController(text: '20');

  final Map<String, double> _allocations = {
    'actions': 40,
    'obligations': 20,
    'immobilier': 15,
    'crypto': 10,
    'epargne': 15,
  };

  List<double>? _portfolioValues;
  List<double>? _investedValues;

  @override
  void dispose() {
    _initialController.dispose();
    _monthlyController.dispose();
    _yearsController.dispose();
    super.dispose();
  }

  double _parse(TextEditingController controller) {
    return double.tryParse(controller.text.replaceAll(',', '.')) ?? 0;
  }

  void _onAllocationChanged(String key, double newValue) {
    setState(() {
      final oldValue = _allocations[key]!;
      final delta = newValue - oldValue;
      _allocations[key] = newValue;

      final others = _allocations.keys.where((k) => k != key).toList();
      final othersSum = others.fold<double>(0, (s, k) => s + _allocations[k]!);
      if (othersSum > 0) {
        for (final k in others) {
          final share = _allocations[k]! / othersSum;
          _allocations[k] = (_allocations[k]! - delta * share).clamp(0, 100);
        }
      }

      final total = _allocations.values.fold<double>(0, (s, v) => s + v);
      if (total > 0) {
        final factor = 100 / total;
        _allocations.updateAll((k, v) => v * factor);
      }
    });
  }

  double _gaussianSample(Random random) {
    final u1 = random.nextDouble().clamp(1e-9, 1.0);
    final u2 = random.nextDouble();
    return sqrt(-2 * log(u1)) * cos(2 * pi * u2);
  }

  void _runSimulation() {
    final initial = _parse(_initialController);
    final monthly = _parse(_monthlyController);
    final years = _parse(_yearsController).clamp(1, 40).toInt();
    final random = Random();

    final pockets = <String, double>{
      for (final asset in simulationAssetClasses)
        asset.key: initial * (_allocations[asset.key]! / 100),
    };

    final portfolioValues = <double>[initial];
    final investedValues = <double>[initial];

    for (int year = 1; year <= years; year++) {
      for (final asset in simulationAssetClasses) {
        final allocation = _allocations[asset.key]! / 100;
        final annualContribution = monthly * 12 * allocation;
        final returnRate = asset.expectedReturn + asset.volatility * _gaussianSample(random);
        final value = (pockets[asset.key]! + annualContribution) * (1 + returnRate);
        pockets[asset.key] = value.clamp(0, double.infinity);
      }
      portfolioValues.add(pockets.values.fold<double>(0, (s, v) => s + v));
      investedValues.add(initial + monthly * 12 * year);
    }

    setState(() {
      _portfolioValues = portfolioValues;
      _investedValues = investedValues;
    });
  }

  @override
  Widget build(BuildContext context) {
    final totalAllocation = _allocations.values.fold<double>(0, (s, v) => s + v);
    final portfolioValues = _portfolioValues;
    final investedValues = _investedValues;

    final finalValue = portfolioValues?.last;
    final totalInvested = investedValues?.last;
    final gain = (finalValue != null && totalInvested != null) ? finalValue - totalInvested : null;
    final years = _parse(_yearsController).clamp(1, 40).toInt();
    final annualizedReturn = (finalValue != null && totalInvested != null && totalInvested > 0)
        ? pow(finalValue / totalInvested, 1 / years) - 1
        : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Simulateur de portefeuille')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          Text(
            'Testez une répartition virtuelle entre plusieurs classes d\'actifs et '
            'observez une évolution simulée, intégrant rendement moyen et volatilité '
            'réaliste. Aucune donnée de marché réelle n\'est utilisée.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                ),
          ),
          const SizedBox(height: 20),
          CalculatorField(label: 'Capital initial', controller: _initialController, suffixText: '€', onChanged: (_) => setState(() {})),
          CalculatorField(label: 'Versement mensuel', controller: _monthlyController, suffixText: '€', onChanged: (_) => setState(() {})),
          CalculatorField(label: 'Durée', controller: _yearsController, suffixText: 'années', onChanged: (_) => setState(() {})),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Allocation', style: Theme.of(context).textTheme.titleLarge),
              Text(
                '${totalAllocation.round()} %',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Ajustez la part de chaque classe d\'actif (le total reste à 100 %).',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
          ),
          const SizedBox(height: 8),
          for (final asset in simulationAssetClasses)
            _AllocationSlider(
              label: asset.label,
              value: _allocations[asset.key]!,
              color: AppColors.categoryColor(asset.colorKey),
              onChanged: (value) => _onAllocationChanged(asset.key, value),
            ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _runSimulation,
              icon: const Icon(Icons.casino),
              label: Text(portfolioValues == null ? 'Lancer la simulation' : 'Relancer la simulation'),
            ),
          ),
          if (portfolioValues != null && investedValues != null) ...[
            const SizedBox(height: 24),
            Text('Résultat', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            ResultTile(
              label: 'Capital final simulé',
              value: formatEuro(finalValue!),
              numericValue: finalValue,
              formatter: formatEuro,
              color: AppColors.primary,
              highlight: true,
            ),
            ResultTile(
              label: 'Total versé',
              value: formatEuro(totalInvested!),
              numericValue: totalInvested,
              formatter: formatEuro,
            ),
            ResultTile(
              label: gain! >= 0 ? 'Gain simulé' : 'Perte simulée',
              value: formatEuro(gain),
              numericValue: gain,
              formatter: formatEuro,
              color: gain >= 0 ? AppColors.success : AppColors.danger,
            ),
            ResultTile(
              label: 'Rendement annuel moyen estimé',
              value: formatPercent((annualizedReturn ?? 0) * 100),
              numericValue: (annualizedReturn ?? 0) * 100,
              formatter: (v) => formatPercent(v),
              color: (annualizedReturn ?? 0) >= 0 ? AppColors.success : AppColors.danger,
            ),
            const SizedBox(height: 16),
            Text('Évolution simulée', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            SizedBox(
              height: 220,
              child: _SimulationChart(portfolioValues: portfolioValues, investedValues: investedValues),
            ).animate().fadeIn(duration: 450.ms).slideY(begin: 0.08, end: 0, curve: Curves.easeOutCubic),
            const SizedBox(height: 12),
            Row(
              children: [
                _Legend(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5), label: 'Total versé'),
                const SizedBox(width: 16),
                _Legend(color: AppColors.primary, label: 'Portefeuille simulé'),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, color: AppColors.info),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Simulation pédagogique basée sur des hypothèses de rendement et de '
                      'volatilité par classe d\'actif. Chaque relance génère un nouveau '
                      'tirage aléatoire : les résultats varient, comme sur de vrais marchés.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AllocationSlider extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final ValueChanged<double> onChanged;

  const _AllocationSlider({
    required this.label,
    required this.value,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 86,
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Expanded(
            child: Slider(
              value: value.clamp(0, 100),
              min: 0,
              max: 100,
              activeColor: color,
              onChanged: onChanged,
            ),
          ),
          SizedBox(
            width: 44,
            child: Text(
              '${value.round()} %',
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
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

class _SimulationChart extends StatelessWidget {
  final List<double> portfolioValues;
  final List<double> investedValues;

  const _SimulationChart({required this.portfolioValues, required this.investedValues});

  @override
  Widget build(BuildContext context) {
    final portfolioSpots = portfolioValues
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();
    final investedSpots = investedValues
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();

    final allValues = [...portfolioValues, ...investedValues];
    final minY = allValues.reduce((a, b) => a < b ? a : b);
    final maxY = allValues.reduce((a, b) => a > b ? a : b);
    final padding = (maxY - minY) * 0.1 == 0 ? maxY * 0.1 : (maxY - minY) * 0.1;
    final years = portfolioValues.length - 1;
    final outline = Theme.of(context).colorScheme.outline;

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
              interval: years > 10 ? (years / 5).ceilToDouble() : 1,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx > years) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text('${idx}a', style: Theme.of(context).textTheme.bodySmall),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: investedSpots,
            isCurved: false,
            color: outline.withValues(alpha: 0.5),
            barWidth: 2,
            dotData: const FlDotData(show: false),
            dashArray: [6, 4],
          ),
          LineChartBarData(
            spots: portfolioSpots,
            isCurved: true,
            color: AppColors.primary,
            barWidth: 3,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: true, color: AppColors.primary.withValues(alpha: 0.12)),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => AppColors.primary,
            getTooltipItems: (spots) => spots.map((spot) {
              return LineTooltipItem(
                'Année ${spot.x.toInt()}\n${formatEuro(spot.y)}',
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
