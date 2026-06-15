class CompoundInterestYear {
  final int year;
  final double invested;
  final double balance;

  const CompoundInterestYear({
    required this.year,
    required this.invested,
    required this.balance,
  });
}

class CompoundInterestResult {
  final List<CompoundInterestYear> yearlyData;
  final double finalBalance;
  final double totalInvested;
  final double interestEarned;

  const CompoundInterestResult({
    required this.yearlyData,
    required this.finalBalance,
    required this.totalInvested,
    required this.interestEarned,
  });
}

/// Calcule l'évolution d'une épargne avec versements mensuels et intérêts
/// composés mensuellement.
CompoundInterestResult calculateCompoundInterest({
  required double initial,
  required double monthly,
  required double annualRatePercent,
  required int years,
}) {
  final monthlyRate = annualRatePercent / 100 / 12;
  final yearlyData = <CompoundInterestYear>[];

  double balance = initial;
  double invested = initial;

  for (int year = 1; year <= years; year++) {
    for (int month = 0; month < 12; month++) {
      balance = balance * (1 + monthlyRate) + monthly;
      invested += monthly;
    }
    yearlyData.add(CompoundInterestYear(year: year, invested: invested, balance: balance));
  }

  final finalBalance = yearlyData.isNotEmpty ? yearlyData.last.balance : initial;
  final totalInvested = yearlyData.isNotEmpty ? yearlyData.last.invested : initial;

  return CompoundInterestResult(
    yearlyData: yearlyData,
    finalBalance: finalBalance,
    totalInvested: totalInvested,
    interestEarned: finalBalance - totalInvested,
  );
}
