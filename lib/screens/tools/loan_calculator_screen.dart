import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../utils/formatters.dart';
import '../../widgets/calculator_field.dart';
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
    final years = _parse(_yearsController).clamp(1, 40);
    final months = (years * 12).round();
    final monthlyRate = annualRate / 100 / 12;

    double monthlyPayment;
    if (amount <= 0 || months <= 0) {
      monthlyPayment = 0;
    } else if (monthlyRate == 0) {
      monthlyPayment = amount / months;
    } else {
      monthlyPayment = amount * monthlyRate / (1 - math.pow(1 + monthlyRate, -months));
    }

    final totalCost = monthlyPayment * months;
    final totalInterest = totalCost - amount;
    final color = AppColors.categoryColor('obligations');

    return Scaffold(
      appBar: AppBar(title: const Text('Capacité d\'emprunt')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          Text(
            'Calculez la mensualité et le coût total d\'un prêt en fonction du montant, du taux et de la durée.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                ),
          ),
          const SizedBox(height: 20),
          CalculatorField(label: 'Montant emprunté', controller: _amountController, suffixText: '€', onChanged: (_) => setState(() {})),
          CalculatorField(label: 'Taux d\'intérêt annuel', controller: _rateController, suffixText: '%', onChanged: (_) => setState(() {})),
          CalculatorField(label: 'Durée du prêt', controller: _yearsController, suffixText: 'années', onChanged: (_) => setState(() {})),
          const SizedBox(height: 8),
          Text('Résultat', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
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
          const SizedBox(height: 8),
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
                    'Les banques considèrent généralement qu\'un taux d\'endettement supérieur à 35 % des revenus nets est risqué. Pensez à vérifier votre capacité de remboursement.',
                    style: Theme.of(context).textTheme.bodySmall,
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
