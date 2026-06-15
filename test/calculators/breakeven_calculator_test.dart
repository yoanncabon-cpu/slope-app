import 'package:flutter_test/flutter_test.dart';
import 'package:slope/calculators/breakeven_calculator.dart';

void main() {
  group('calculateBreakeven', () {
    test('calcule le seuil de rentabilité pour un cas viable', () {
      final result = calculateBreakeven(fixedCosts: 3000, price: 25, variableCost: 10);

      expect(result.unitMargin, 15);
      expect(result.isViable, isTrue);
      expect(result.breakevenUnits, closeTo(200, 1e-9));
      expect(result.breakevenRevenue, closeTo(5000, 1e-9));
      expect(result.marginRatePercent, closeTo(60, 1e-9));
    });

    test('marge unitaire nulle ou négative : non viable', () {
      final result = calculateBreakeven(fixedCosts: 3000, price: 10, variableCost: 10);

      expect(result.unitMargin, 0);
      expect(result.isViable, isFalse);
      expect(result.breakevenUnits, 0);
      expect(result.breakevenRevenue, 0);
    });

    test('prix nul : taux de marge à zéro pour éviter une division par zéro', () {
      final result = calculateBreakeven(fixedCosts: 1000, price: 0, variableCost: -5);

      expect(result.unitMargin, 5);
      expect(result.isViable, isTrue);
      expect(result.marginRatePercent, 0);
      expect(result.breakevenRevenue, 0);
    });
  });
}
