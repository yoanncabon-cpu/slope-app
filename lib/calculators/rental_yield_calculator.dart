class RentalYieldResult {
  final double totalInvestment;
  final double grossYieldPercent;
  final double netYieldPercent;
  final double monthlyCashflow;

  const RentalYieldResult({
    required this.totalInvestment,
    required this.grossYieldPercent,
    required this.netYieldPercent,
    required this.monthlyCashflow,
  });
}

/// Calcule le rendement brut/net et le cashflow mensuel d'un investissement
/// locatif.
RentalYieldResult calculateRentalYield({
  required double price,
  required double fees,
  required double monthlyRent,
  required double annualCharges,
}) {
  final totalInvestment = price + fees;
  final annualRent = monthlyRent * 12;
  final grossYield = totalInvestment > 0 ? annualRent / totalInvestment * 100 : 0.0;
  final netIncome = annualRent - annualCharges;
  final netYield = totalInvestment > 0 ? netIncome / totalInvestment * 100 : 0.0;
  final monthlyCashflow = netIncome / 12;

  return RentalYieldResult(
    totalInvestment: totalInvestment,
    grossYieldPercent: grossYield,
    netYieldPercent: netYield,
    monthlyCashflow: monthlyCashflow,
  );
}
