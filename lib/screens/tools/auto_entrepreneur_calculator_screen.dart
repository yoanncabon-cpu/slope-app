import 'package:flutter/material.dart';

import '../../calculators/auto_entrepreneur_calculator.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatters.dart';
import '../../widgets/alert_banner.dart';
import '../../widgets/animations/animations.dart';
import '../../widgets/calculator_field.dart';
import '../../widgets/illustration_banner.dart';
import '../../widgets/result_tile.dart';

const Map<AutoEntrepreneurActivity, String> _activityLabels = {
  AutoEntrepreneurActivity.vente: 'Vente de marchandises',
  AutoEntrepreneurActivity.prestationBic: 'Prestations de services (BIC)',
  AutoEntrepreneurActivity.prestationBnc: 'Prestations de services (BNC)',
  AutoEntrepreneurActivity.liberaleReglementee: 'Activité libérale réglementée',
};

class AutoEntrepreneurCalculatorScreen extends StatefulWidget {
  const AutoEntrepreneurCalculatorScreen({super.key});

  @override
  State<AutoEntrepreneurCalculatorScreen> createState() => _AutoEntrepreneurCalculatorScreenState();
}

class _AutoEntrepreneurCalculatorScreenState extends State<AutoEntrepreneurCalculatorScreen> {
  final _revenueController = TextEditingController(text: '3000');
  AutoEntrepreneurActivity _activity = AutoEntrepreneurActivity.vente;
  bool _versementLiberatoire = false;

  @override
  void dispose() {
    _revenueController.dispose();
    super.dispose();
  }

  double _parse(TextEditingController controller) {
    return double.tryParse(controller.text.replaceAll(',', '.')) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final revenue = _parse(_revenueController);
    final revenueError = revenue <= 0 ? 'Saisissez un chiffre d\'affaires pour estimer vos cotisations' : null;

    final result = calculateAutoEntrepreneur(
      revenue: revenue,
      activity: _activity,
      versementLiberatoire: _versementLiberatoire,
    );

    final color = AppColors.categoryColor('financement');

    return Scaffold(
      appBar: AppBar(title: const Text('Cotisations auto-entrepreneur')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        children: [
          const IllustrationBanner(
            asset: 'assets/images/illustration_tools.svg',
            horizontalPadding: 0,
          ),
          Text(
            'Estimez vos cotisations sociales et votre revenu net en micro-entreprise '
            'à partir de votre chiffre d\'affaires mensuel.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                ),
          ),
          const SizedBox(height: 20),
          CalculatorField(label: 'Chiffre d\'affaires mensuel', controller: _revenueController, suffixText: '€', errorText: revenueError, onChanged: (_) => setState(() {})),
          const SizedBox(height: 8),
          Text('Type d\'activité', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final activity in AutoEntrepreneurActivity.values)
                ChoiceChip(
                  label: Text(_activityLabels[activity]!),
                  selected: _activity == activity,
                  onSelected: (_) => setState(() => _activity = activity),
                ),
            ],
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Versement fiscal libératoire'),
            subtitle: const Text('Paie l\'impôt sur le revenu en même temps que les cotisations'),
            value: _versementLiberatoire,
            onChanged: (value) => setState(() => _versementLiberatoire = value),
          ),
          const SizedBox(height: 8),
          Text('Résultat', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          StaggerFadeSlide(
            index: 0,
            child: Column(
              children: [
                ResultTile(
                  label: 'Cotisations sociales',
                  value: formatEuro(result.socialContributions, decimals: true),
                  numericValue: result.socialContributions,
                  formatter: (v) => formatEuro(v, decimals: true),
                  color: AppColors.warning,
                ),
                if (result.incomeTaxLiberatoire != null)
                  ResultTile(
                    label: 'Impôt sur le revenu (versement libératoire)',
                    value: formatEuro(result.incomeTaxLiberatoire!, decimals: true),
                    numericValue: result.incomeTaxLiberatoire!,
                    formatter: (v) => formatEuro(v, decimals: true),
                    color: AppColors.warning,
                  ),
                ResultTile(
                  label: 'Revenu net mensuel estimé',
                  value: formatEuro(result.netIncomeAfterTax, decimals: true),
                  numericValue: result.netIncomeAfterTax,
                  formatter: (v) => formatEuro(v, decimals: true),
                  color: color,
                  highlight: true,
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
                  'Taux indicatifs (cotisations et versement libératoire), à vérifier sur '
                  'autoentrepreneur.urssaf.fr : ils évoluent régulièrement et dépendent de '
                  'dispositifs comme l\'ACRE.',
            ),
          ),
        ],
      ),
    );
  }
}
