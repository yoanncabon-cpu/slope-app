import 'package:flutter_test/flutter_test.dart';
import 'package:slope/calculators/compound_interest_calculator.dart';

void main() {
  group('calculateCompoundInterest', () {
    test('produit une donnée par année et un capital final supérieur au total versé', () {
      final result = calculateCompoundInterest(
        initial: 1000,
        monthly: 100,
        annualRatePercent: 5,
        years: 15,
      );

      expect(result.yearlyData.length, 15);
      expect(result.yearlyData.first.year, 1);
      expect(result.yearlyData.last.year, 15);
      expect(result.totalInvested, 1000 + 100 * 12 * 15);
      expect(result.finalBalance, greaterThan(result.totalInvested));
      expect(result.interestEarned, closeTo(result.finalBalance - result.totalInvested, 1e-9));
    });

    test('sans versements et sans intérêts, le capital reste constant', () {
      final result = calculateCompoundInterest(
        initial: 1000,
        monthly: 0,
        annualRatePercent: 0,
        years: 1,
      );

      expect(result.finalBalance, closeTo(1000, 1e-9));
      expect(result.totalInvested, closeTo(1000, 1e-9));
      expect(result.interestEarned, closeTo(0, 1e-9));
    });

    test('sans intérêts, le capital final correspond au capital initial + versements', () {
      final result = calculateCompoundInterest(
        initial: 0,
        monthly: 100,
        annualRatePercent: 0,
        years: 1,
      );

      expect(result.finalBalance, closeTo(1200, 1e-9));
      expect(result.totalInvested, closeTo(1200, 1e-9));
      expect(result.interestEarned, closeTo(0, 1e-9));
    });

    test('avec 0 année, retourne les valeurs initiales sans intérêts', () {
      final result = calculateCompoundInterest(
        initial: 500,
        monthly: 50,
        annualRatePercent: 5,
        years: 0,
      );

      expect(result.yearlyData, isEmpty);
      expect(result.finalBalance, 500);
      expect(result.totalInvested, 500);
      expect(result.interestEarned, 0);
    });

    test('calcule correctement les intérêts composés sur un capital sans versement', () {
      final result = calculateCompoundInterest(
        initial: 1000,
        monthly: 0,
        annualRatePercent: 12,
        years: 1,
      );

      // 1000 * (1 + 0.01)^12 ≈ 1126.83
      expect(result.finalBalance, closeTo(1126.83, 0.01));
      expect(result.totalInvested, closeTo(1000, 1e-9));
    });
  });
}
