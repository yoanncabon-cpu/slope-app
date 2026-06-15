class BreakevenResult {
  final double unitMargin;
  final double marginRatePercent;
  final double breakevenUnits;
  final double breakevenRevenue;
  final bool isViable;

  const BreakevenResult({
    required this.unitMargin,
    required this.marginRatePercent,
    required this.breakevenUnits,
    required this.breakevenRevenue,
    required this.isViable,
  });
}

/// Calcule le seuil de rentabilité (unités et chiffre d'affaires) à partir
/// des charges fixes, du prix de vente et du coût variable unitaire.
BreakevenResult calculateBreakeven({
  required double fixedCosts,
  required double price,
  required double variableCost,
}) {
  final unitMargin = price - variableCost;
  final isViable = unitMargin > 0;
  final breakevenUnits = isViable ? fixedCosts / unitMargin : 0.0;
  final breakevenRevenue = breakevenUnits * price;
  final marginRate = price > 0 ? unitMargin / price * 100 : 0.0;

  return BreakevenResult(
    unitMargin: unitMargin,
    marginRatePercent: marginRate,
    breakevenUnits: breakevenUnits,
    breakevenRevenue: breakevenRevenue,
    isViable: isViable,
  );
}
