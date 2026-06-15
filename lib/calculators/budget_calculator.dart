class BudgetResult {
  final double needs;
  final double wants;
  final double savings;

  const BudgetResult({
    required this.needs,
    required this.wants,
    required this.savings,
  });
}

/// Répartit un revenu mensuel net selon la règle 50/30/20
/// (besoins essentiels / envies / épargne).
BudgetResult calculateBudget503020({required double income}) {
  return BudgetResult(
    needs: income * 0.5,
    wants: income * 0.3,
    savings: income * 0.2,
  );
}
