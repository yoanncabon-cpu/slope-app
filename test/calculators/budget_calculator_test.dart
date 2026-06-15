import 'package:flutter_test/flutter_test.dart';
import 'package:slope/calculators/budget_calculator.dart';

void main() {
  group('calculateBudget503020', () {
    test('répartit le revenu selon la règle 50/30/20', () {
      final result = calculateBudget503020(income: 2500);

      expect(result.needs, closeTo(1250, 1e-9));
      expect(result.wants, closeTo(750, 1e-9));
      expect(result.savings, closeTo(500, 1e-9));
      expect(result.needs + result.wants + result.savings, closeTo(2500, 1e-9));
    });

    test('revenu nul : toutes les parts sont nulles', () {
      final result = calculateBudget503020(income: 0);

      expect(result.needs, 0);
      expect(result.wants, 0);
      expect(result.savings, 0);
    });
  });
}
