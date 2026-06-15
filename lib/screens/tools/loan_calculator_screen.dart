import 'package:flutter/material.dart';

import '../../calculators/loan_calculator.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatters.dart';
import '../../widgets/alert_banner.dart';
import '../../widgets/animations/animations.dart';
import '../../widgets/calculator_field.dart';
import '../../widgets/illustration_banner.dart';
import '../../widgets/result_tile.dart';

class LoanCalculatorScreen extends StatefulWidget {
  const LoanCalculatorScreen({super.key});

  @override
  State<LoanCalculatorScreen> createState() => _LoanCalculatorScreenState();
}

class _LoanCalculatorScreenState extends State<LoanCalculatorScreen> {
  final _amountController = TextEditingController(text: '200000');
  final _rateController = TextEditingController(text: '3.5');
  final _yearsController = TextEditingController(text: '20');

  @override
  void dispose() {
    _amountController.dispose();
    _rateController.dispose();
    _yearsController.dispose();
    super.dispose();
  }

  double _parse(TextEditingController controller) {
    return double.tryParse(controller.text.replaceAll(',', '.')) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final amount = _parse(_amountController);
    final annualRate = _parse(_rateController);
    final years = _parse(_yearsController);
    final amountError = amount <= 0 ? 'Le montant emprunté doit être supérieur à 0' : null;
    final yearsError = years <= 0 ? 'La durée doit être supérieure à 0' : null;

    final result = calculateLoan(amount: amount, annualRatePercent: annualRate, years: years);
    final monthlyPayment = result.monthlyPayment;
    final totalCost = result.totalCost;
    final totalInterest = result.totalInterest;
    final color = AppColors.categoryColor('obligations');

    return Scaffold(
      appBar: AppBar(title: const Text('Capacité d\'emprunt')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        children: [
          const IllustrationBanner(
            asset: 'assets/images/illustration_tools.svg',
            horizontalPadding: 0,
          ),
          Text(
            'Calculez la mensualité et le coût total d\'un prêt en fonction du montant, du taux et de la durée.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                ),
          ),
          const SizedBox(height: 20),
          CalculatorField(label: 'Montant emprunté', controller: _amountController, suffixText: '€', errorText: amountError, onChanged: (_) => setState(() {})),
          CalculatorField(label: 'Taux d\'intérêt annuel', controller: _rateController, suffixText: '%', onChanged: (_) => setState(() {})),
          CalculatorField(label: 'Durée du prêt', controller: _yearsController, suffixText: 'années', errorText: yearsError, onChanged: (_) => setState(() {})),
          const SizedBox(height: 8),
          Text('Résultat', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          StaggerFadeSlide(
            index: 0,
            child: Column(
              children: [
                ResultTile(
                  label: 'Mensualité',
                  value: formatEuro(monthlyPayment, decimals: true),
                  numericValue: monthlyPayment,
                  formatter: (v) => formatEuro(v, decimals: true),
                  color: color,
                  highlight: true,
                ),
                ResultTile(
                  label: 'Coût total du crédit',
                  value: formatEuro(totalCost),
                  numericValue: totalCost,
                  formatter: formatEuro,
                ),
                ResultTile(
                  label: 'Total des intérêts payés',
                  value: formatEuro(totalInterest),
                  numericValue: totalInterest,
                  formatter: formatEuro,
                  color: AppColors.warning,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          StaggerFadeSlide(
            index: 1,
            child: const AlertBanner(
              type: AlertType.info,
              message:
                  'Les banques considèrent généralement qu\'un taux d\'endettement supérieur à 35 % des revenus nets est risqué. Pensez à vérifier votre capacité de remboursement.',
            ),
          ),
        ],
      ),
    );
  }
}
