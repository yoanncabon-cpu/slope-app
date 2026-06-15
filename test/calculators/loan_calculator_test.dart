import 'package:flutter_test/flutter_test.dart';
import 'package:slope/calculators/loan_calculator.dart';

void main() {
  group('calculateLoan', () {
    test('calcule une mensualité cohérente pour un prêt classique', () {
      final result = calculateLoan(amount: 200000, annualRatePercent: 3.5, years: 20);

      expect(result.monthlyPayment, closeTo(1160, 1));
      expect(result.totalCost, closeTo(result.monthlyPayment * 240, 1e-6));
      expect(result.totalInterest, closeTo(result.totalCost - 200000, 1e-9));
      expect(result.totalInterest, greaterThan(0));
    });

    test('taux à 0 % : la mensualité est le montant divisé par le nombre de mois', () {
      final result = calculateLoan(amount: 120000, annualRatePercent: 0, years: 10);

      expect(result.monthlyPayment, closeTo(1000, 1e-9));
      expect(result.totalCost, closeTo(120000, 1e-9));
      expect(result.totalInterest, closeTo(0, 1e-9));
    });

    test('montant nul : tout est à zéro', () {
      final result = calculateLoan(amount: 0, annualRatePercent: 3.5, years: 20);

      expect(result.monthlyPayment, 0);
      expect(result.totalCost, 0);
      expect(result.totalInterest, 0);
    });

    test('la durée est bornée entre 1 et 40 ans', () {
      final short = calculateLoan(amount: 10000, annualRatePercent: 2, years: 0);
      final long = calculateLoan(amount: 10000, annualRatePercent: 2, years: 100);

      // 0 ans -> clampé à 1 an (12 mois), 100 ans -> clampé à 40 ans (480 mois)
      expect(short.totalCost, closeTo(short.monthlyPayment * 12, 1e-6));
      expect(long.totalCost, closeTo(long.monthlyPayment * 480, 1e-6));
    });
  });
}
