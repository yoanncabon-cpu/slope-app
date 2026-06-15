import 'package:flutter/material.dart';

import '../../calculators/rental_yield_calculator.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatters.dart';
import '../../widgets/alert_banner.dart';
import '../../widgets/animations/animations.dart';
import '../../widgets/calculator_field.dart';
import '../../widgets/illustration_banner.dart';
import '../../widgets/result_tile.dart';

class RentalYieldScreen extends StatefulWidget {
  const RentalYieldScreen({super.key});

  @override
  State<RentalYieldScreen> createState() => _RentalYieldScreenState();
}

class _RentalYieldScreenState extends State<RentalYieldScreen> {
  final _priceController = TextEditingController(text: '200000');
  final _feesController = TextEditingController(text: '15000');
  final _rentController = TextEditingController(text: '800');
  final _chargesController = TextEditingController(text: '1500');

  @override
  void dispose() {
    _priceController.dispose();
    _feesController.dispose();
    _rentController.dispose();
    _chargesController.dispose();
    super.dispose();
  }

  double _parse(TextEditingController controller) {
    return double.tryParse(controller.text.replaceAll(',', '.')) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final price = _parse(_priceController);
    final fees = _parse(_feesController);
    final monthlyRent = _parse(_rentController);
    final annualCharges = _parse(_chargesController);
    final priceError = price <= 0 ? 'Le prix d\'achat doit être supérieur à 0' : null;
    final rentError = monthlyRent <= 0 ? 'Le loyer doit être supérieur à 0' : null;

    final result = calculateRentalYield(
      price: price,
      fees: fees,
      monthlyRent: monthlyRent,
      annualCharges: annualCharges,
    );
    final totalInvestment = result.totalInvestment;
    final grossYield = result.grossYieldPercent;
    final netYield = result.netYieldPercent;
    final monthlyCashflow = result.monthlyCashflow;

    final color = AppColors.categoryColor('immobilier');

    return Scaffold(
      appBar: AppBar(title: const Text('Rendement locatif')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        children: [
          const IllustrationBanner(
            asset: 'assets/images/illustration_tools.svg',
            horizontalPadding: 0,
          ),
          Text(
            'Estimez la rentabilité d\'un investissement immobilier locatif, frais et charges inclus.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                ),
          ),
          const SizedBox(height: 20),
          CalculatorField(label: 'Prix d\'achat du bien', controller: _priceController, suffixText: '€', errorText: priceError, onChanged: (_) => setState(() {})),
          CalculatorField(label: 'Frais d\'acquisition (notaire, travaux...)', controller: _feesController, suffixText: '€', onChanged: (_) => setState(() {})),
          CalculatorField(label: 'Loyer mensuel hors charges', controller: _rentController, suffixText: '€', errorText: rentError, onChanged: (_) => setState(() {})),
          CalculatorField(label: 'Charges annuelles (taxe foncière, gestion, assurance...)', controller: _chargesController, suffixText: '€', onChanged: (_) => setState(() {})),
          const SizedBox(height: 8),
          Text('Résultat', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          StaggerFadeSlide(
            index: 0,
            child: Column(
              children: [
                ResultTile(
                  label: 'Investissement total',
                  value: formatEuro(totalInvestment),
                  numericValue: totalInvestment,
                  formatter: formatEuro,
                ),
                ResultTile(
                  label: 'Rendement brut',
                  value: formatPercent(grossYield),
                  numericValue: grossYield,
                  formatter: formatPercent,
                  color: color,
                  highlight: true,
                ),
                ResultTile(
                  label: 'Rendement net',
                  value: formatPercent(netYield),
                  numericValue: netYield,
                  formatter: formatPercent,
                  color: AppColors.success,
                  highlight: true,
                ),
                ResultTile(
                  label: 'Cashflow mensuel net',
                  value: formatEuro(monthlyCashflow, decimals: true),
                  numericValue: monthlyCashflow,
                  formatter: (v) => formatEuro(v, decimals: true),
                  color: monthlyCashflow >= 0 ? AppColors.success : AppColors.danger,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const AlertBanner(
            type: AlertType.info,
            message:
                'Cette estimation ne prend pas en compte la fiscalité, les périodes '
                'de vacance locative ni l\'évolution du marché immobilier.',
          ),
        ],
      ),
    );
  }
}
