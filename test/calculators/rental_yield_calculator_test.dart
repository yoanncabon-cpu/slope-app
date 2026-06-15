import 'package:flutter_test/flutter_test.dart';
import 'package:slope/calculators/rental_yield_calculator.dart';

void main() {
  group('calculateRentalYield', () {
    test('calcule rendements et cashflow pour un cas nominal', () {
      final result = calculateRentalYield(
        price: 200000,
        fees: 15000,
        monthlyRent: 800,
        annualCharges: 1500,
      );

      expect(result.totalInvestment, 215000);
      expect(result.grossYieldPercent, closeTo(4.4651, 0.0001));
      expect(result.netYieldPercent, closeTo(3.7674, 0.0001));
      expect(result.monthlyCashflow, closeTo(675, 1e-9));
    });

    test('investissement nul : rendements à zéro mais cashflow calculé', () {
      final result = calculateRentalYield(
        price: 0,
        fees: 0,
        monthlyRent: 800,
        annualCharges: 0,
      );

      expect(result.totalInvestment, 0);
      expect(result.grossYieldPercent, 0);
      expect(result.netYieldPercent, 0);
      expect(result.monthlyCashflow, closeTo(800, 1e-9));
    });

    test('charges supérieures aux loyers : cashflow négatif', () {
      final result = calculateRentalYield(
        price: 100000,
        fees: 5000,
        monthlyRent: 100,
        annualCharges: 2000,
      );

      expect(result.monthlyCashflow, lessThan(0));
      expect(result.netYieldPercent, lessThan(result.grossYieldPercent));
    });
  });
}
