/// Classe d'actif simulée dans le simulateur de portefeuille.
///
/// `expectedReturn` et `volatility` sont des moyennes annuelles indicatives
/// (en fraction, ex. 0.07 = 7 %) utilisées pour générer des tirages aléatoires
/// réalistes — il ne s'agit pas de données de marché réelles.
class SimulationAssetClass {
  final String key;
  final String label;
  final String colorKey;
  final double expectedReturn;
  final double volatility;

  const SimulationAssetClass({
    required this.key,
    required this.label,
    required this.colorKey,
    required this.expectedReturn,
    required this.volatility,
  });
}

const List<SimulationAssetClass> simulationAssetClasses = [
  SimulationAssetClass(
    key: 'actions',
    label: 'Actions',
    colorKey: 'actions',
    expectedReturn: 0.07,
    volatility: 0.18,
  ),
  SimulationAssetClass(
    key: 'obligations',
    label: 'Obligations',
    colorKey: 'obligations',
    expectedReturn: 0.03,
    volatility: 0.05,
  ),
  SimulationAssetClass(
    key: 'immobilier',
    label: 'Immobilier',
    colorKey: 'immobilier',
    expectedReturn: 0.04,
    volatility: 0.08,
  ),
  SimulationAssetClass(
    key: 'crypto',
    label: 'Crypto',
    colorKey: 'crypto',
    expectedReturn: 0.15,
    volatility: 0.55,
  ),
  SimulationAssetClass(
    key: 'epargne',
    label: 'Épargne',
    colorKey: 'epargne',
    expectedReturn: 0.02,
    volatility: 0.005,
  ),
];
