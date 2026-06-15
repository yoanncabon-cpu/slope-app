import 'dart:math' as math;

class LoanResult {
  final double monthlyPayment;
  final double totalCost;
  final double totalInterest;

  const LoanResult({
    required this.monthlyPayment,
    required this.totalCost,
    required this.totalInterest,
  });
}

/// Calcule la mensualité, le coût total et les intérêts totaux d'un prêt
/// amortissable à taux fixe.
LoanResult calculateLoan({
  required double amount,
  required double annualRatePercent,
  required double years,
}) {
  final clampedYears = years.clamp(1, 40);
  final months = (clampedYears * 12).round();
  final monthlyRate = annualRatePercent / 100 / 12;

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

  return LoanResult(
    monthlyPayment: monthlyPayment,
    totalCost: totalCost,
    totalInterest: totalInterest,
  );
}
