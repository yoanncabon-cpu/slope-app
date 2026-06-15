import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:slope/calculators/portfolio_allocation.dart';
import 'package:slope/models/simulation_asset_class.dart';

void main() {
  group('rebalanceAllocations', () {
    test('redistribue le delta proportionnellement entre les autres classes', () {
      final allocations = {
        'actions': 40.0,
        'obligations': 20.0,
        'immobilier': 15.0,
        'crypto': 10.0,
        'epargne': 15.0,
      };

      final result = rebalanceAllocations(allocations, 'actions', 60);

      expect(result['actions'], 60);
      expect(result['obligations'], closeTo(13.3333, 0.0001));
      expect(result['immobilier'], closeTo(10, 0.0001));
      expect(result['crypto'], closeTo(6.6667, 0.0001));
      expect(result['epargne'], closeTo(10, 0.0001));
      expect(result.values.fold<double>(0, (s, v) => s + v), closeTo(100, 1e-9));
    });

    test('ne modifie pas la map passée en paramètre', () {
      final allocations = {'a': 50.0, 'b': 50.0};

      rebalanceAllocations(allocations, 'a', 80);

      expect(allocations['a'], 50.0);
      expect(allocations['b'], 50.0);
    });

    test('les autres classes sont bornées à 0 si le delta dépasse leur somme', () {
      final allocations = {
        'actions': 40.0,
        'obligations': 20.0,
        'immobilier': 15.0,
        'crypto': 10.0,
        'epargne': 15.0,
      };

      final result = rebalanceAllocations(allocations, 'actions', 100);

      expect(result['actions'], 100);
      expect(result['obligations'], 0);
      expect(result['immobilier'], 0);
      expect(result['crypto'], 0);
      expect(result['epargne'], 0);
      expect(result.values.fold<double>(0, (s, v) => s + v), closeTo(100, 1e-9));
    });
  });

  group('gaussianSample', () {
    test('est déterministe pour une graine fixée', () {
      final a = gaussianSample(Random(42));
      final b = gaussianSample(Random(42));

      expect(a, b);
    });
  });

  group('simulatePortfolio', () {
    test('retourne une série de valeurs cohérente sur plusieurs années', () {
      final result = simulatePortfolio(
        initial: 10000,
        monthly: 100,
        years: 5,
        allocations: const {
          'actions': 40,
          'obligations': 20,
          'immobilier': 15,
          'crypto': 10,
          'epargne': 15,
        },
        assetClasses: simulationAssetClasses,
        random: Random(42),
      );

      expect(result.portfolioValues.length, 6);
      expect(result.investedValues.length, 6);
      expect(result.portfolioValues.first, 10000);
      expect(result.investedValues.first, 10000);

      for (int year = 1; year <= 5; year++) {
        expect(result.investedValues[year], closeTo(10000 + 100 * 12 * year, 1e-9));
      }

      for (final value in result.portfolioValues) {
        expect(value, greaterThanOrEqualTo(0));
      }
    });
  });
}
