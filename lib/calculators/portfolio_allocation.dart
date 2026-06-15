import 'dart:math';

import '../models/simulation_asset_class.dart';

/// Rééquilibre les allocations (en %) après que [changedKey] ait été modifiée
/// vers [newValue], en répartissant la différence proportionnellement sur les
/// autres classes d'actifs, puis en renormalisant le total à 100 %.
Map<String, double> rebalanceAllocations(
  Map<String, double> allocations,
  String changedKey,
  double newValue,
) {
  final result = Map<String, double>.from(allocations);
  final oldValue = result[changedKey]!;
  final delta = newValue - oldValue;
  result[changedKey] = newValue;

  final others = result.keys.where((k) => k != changedKey).toList();
  final othersSum = others.fold<double>(0, (s, k) => s + result[k]!);
  if (othersSum > 0) {
    for (final k in others) {
      final share = result[k]! / othersSum;
      result[k] = (result[k]! - delta * share).clamp(0, 100);
    }
  }

  final total = result.values.fold<double>(0, (s, v) => s + v);
  if (total > 0) {
    final factor = 100 / total;
    result.updateAll((k, v) => v * factor);
  }

  return result;
}

/// Tire un échantillon suivant une loi normale centrée réduite
/// (transformation de Box-Muller).
double gaussianSample(Random random) {
  final u1 = random.nextDouble().clamp(1e-9, 1.0);
  final u2 = random.nextDouble();
  return sqrt(-2 * log(u1)) * cos(2 * pi * u2);
}

class PortfolioSimulationResult {
  final List<double> portfolioValues;
  final List<double> investedValues;

  const PortfolioSimulationResult({
    required this.portfolioValues,
    required this.investedValues,
  });
}

/// Simule l'évolution d'un portefeuille année par année, avec des tirages
/// aléatoires de rendement par classe d'actif (rendement moyen + volatilité).
PortfolioSimulationResult simulatePortfolio({
  required double initial,
  required double monthly,
  required int years,
  required Map<String, double> allocations,
  required List<SimulationAssetClass> assetClasses,
  required Random random,
}) {
  final pockets = <String, double>{
    for (final asset in assetClasses) asset.key: initial * (allocations[asset.key]! / 100),
  };

  final portfolioValues = <double>[initial];
  final investedValues = <double>[initial];

  for (int year = 1; year <= years; year++) {
    for (final asset in assetClasses) {
      final allocation = allocations[asset.key]! / 100;
      final annualContribution = monthly * 12 * allocation;
      final returnRate = asset.expectedReturn + asset.volatility * gaussianSample(random);
      final value = (pockets[asset.key]! + annualContribution) * (1 + returnRate);
      pockets[asset.key] = value.clamp(0, double.infinity);
    }
    portfolioValues.add(pockets.values.fold<double>(0, (s, v) => s + v));
    investedValues.add(initial + monthly * 12 * year);
  }

  return PortfolioSimulationResult(
    portfolioValues: portfolioValues,
    investedValues: investedValues,
  );
}
