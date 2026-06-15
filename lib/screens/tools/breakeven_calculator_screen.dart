import 'package:flutter/material.dart';

import '../../calculators/breakeven_calculator.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatters.dart';
import '../../widgets/alert_banner.dart';
import '../../widgets/animations/animations.dart';
import '../../widgets/calculator_field.dart';
import '../../widgets/illustration_banner.dart';
import '../../widgets/result_tile.dart';

class BreakevenCalculatorScreen extends StatefulWidget {
  const BreakevenCalculatorScreen({super.key});

  @override
  State<BreakevenCalculatorScreen> createState() => _BreakevenCalculatorScreenState();
}

class _BreakevenCalculatorScreenState extends State<BreakevenCalculatorScreen> {
  final _fixedCostsController = TextEditingController(text: '3000');
  final _priceController = TextEditingController(text: '25');
  final _variableCostController = TextEditingController(text: '10');

  @override
  void dispose() {
    _fixedCostsController.dispose();
    _priceController.dispose();
    _variableCostController.dispose();
    super.dispose();
  }

  double _parse(TextEditingController controller) {
    return double.tryParse(controller.text.replaceAll(',', '.')) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final fixedCosts = _parse(_fixedCostsController);
    final price = _parse(_priceController);
    final variableCost = _parse(_variableCostController);
    final priceError = price <= 0 ? 'Le prix de vente doit être supérieur à 0' : null;

    final result = calculateBreakeven(fixedCosts: fixedCosts, price: price, variableCost: variableCost);
    final unitMargin = result.unitMargin;
    final breakevenUnits = result.breakevenUnits;
    final breakevenRevenue = result.breakevenRevenue;
    final marginRate = result.marginRatePercent;
    final isViable = result.isViable;

    final color = AppColors.categoryColor('gestion');

    return Scaffold(
      appBar: AppBar(title: const Text('Seuil de rentabilité')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        children: [
          const IllustrationBanner(
            asset: 'assets/images/illustration_tools.svg',
            horizontalPadding: 0,
          ),
          Text(
            'Déterminez le volume de ventes mensuel nécessaire pour couvrir vos charges fixes.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                ),
          ),
          const SizedBox(height: 20),
          CalculatorField(label: 'Charges fixes mensuelles', controller: _fixedCostsController, suffixText: '€', onChanged: (_) => setState(() {})),
          CalculatorField(label: 'Prix de vente unitaire', controller: _priceController, suffixText: '€', errorText: priceError, onChanged: (_) => setState(() {})),
          CalculatorField(label: 'Coût variable unitaire', controller: _variableCostController, suffixText: '€', onChanged: (_) => setState(() {})),
          const SizedBox(height: 8),
          Text('Résultat', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          if (!isViable)
            const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: AlertBanner(
                type: AlertType.danger,
                message:
                    'Votre prix de vente est inférieur ou égal à votre coût variable : aucun seuil de rentabilité n\'est atteignable en l\'état.',
              ),
            ),
          StaggerFadeSlide(
            index: 0,
            child: Column(
              children: [
                ResultTile(
                  label: 'Marge unitaire',
                  value: formatEuro(unitMargin, decimals: true),
                  numericValue: unitMargin,
                  formatter: (v) => formatEuro(v, decimals: true),
                ),
                ResultTile(
                  label: 'Taux de marge',
                  value: formatPercent(marginRate),
                  numericValue: marginRate,
                  formatter: formatPercent,
                ),
                ResultTile(
                  label: 'Quantité à vendre / mois',
                  value: '${breakevenUnits.ceil()} unités',
                  numericValue: breakevenUnits,
                  formatter: (v) => '${v.ceil()} unités',
                  color: color,
                  highlight: true,
                ),
                ResultTile(
                  label: 'Chiffre d\'affaires à atteindre / mois',
                  value: formatEuro(breakevenRevenue),
                  numericValue: breakevenRevenue,
                  formatter: formatEuro,
                  color: color,
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
