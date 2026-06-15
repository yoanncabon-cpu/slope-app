import 'package:flutter_test/flutter_test.dart';
import 'package:slope/calculators/auto_entrepreneur_calculator.dart';

void main() {
  group('calculateAutoEntrepreneur', () {
    test('activité vente, sans versement libératoire', () {
      final result = calculateAutoEntrepreneur(
        revenue: 3000,
        activity: AutoEntrepreneurActivity.vente,
        versementLiberatoire: false,
      );

      expect(result.socialContributions, closeTo(3000 * 0.123, 1e-9));
      expect(result.netIncomeBeforeTax, closeTo(3000 - 3000 * 0.123, 1e-9));
      expect(result.incomeTaxLiberatoire, isNull);
      expect(result.netIncomeAfterTax, closeTo(result.netIncomeBeforeTax, 1e-9));
    });

    test('activité vente, avec versement libératoire', () {
      final result = calculateAutoEntrepreneur(
        revenue: 3000,
        activity: AutoEntrepreneurActivity.vente,
        versementLiberatoire: true,
      );

      expect(result.incomeTaxLiberatoire, closeTo(3000 * 0.01, 1e-9));
      expect(result.netIncomeAfterTax, closeTo(result.netIncomeBeforeTax - 3000 * 0.01, 1e-9));
    });

    test('prestation BIC : cotisations plus élevées que pour la vente', () {
      final vente = calculateAutoEntrepreneur(revenue: 2000, activity: AutoEntrepreneurActivity.vente, versementLiberatoire: false);
      final bic = calculateAutoEntrepreneur(revenue: 2000, activity: AutoEntrepreneurActivity.prestationBic, versementLiberatoire: false);

      expect(bic.socialContributions, greaterThan(vente.socialContributions));
      expect(bic.socialContributions, closeTo(2000 * 0.212, 1e-9));
    });

    test('prestation BNC, avec versement libératoire', () {
      final result = calculateAutoEntrepreneur(
        revenue: 2500,
        activity: AutoEntrepreneurActivity.prestationBnc,
        versementLiberatoire: true,
      );

      expect(result.socialContributions, closeTo(2500 * 0.211, 1e-9));
      expect(result.incomeTaxLiberatoire, closeTo(2500 * 0.022, 1e-9));
      expect(result.netIncomeAfterTax, closeTo(2500 - 2500 * 0.211 - 2500 * 0.022, 1e-9));
    });

    test('activité libérale réglementée, sans versement libératoire', () {
      final result = calculateAutoEntrepreneur(
        revenue: 4000,
        activity: AutoEntrepreneurActivity.liberaleReglementee,
        versementLiberatoire: false,
      );

      expect(result.socialContributions, closeTo(4000 * 0.212, 1e-9));
      expect(result.incomeTaxLiberatoire, isNull);
      expect(result.netIncomeAfterTax, closeTo(result.netIncomeBeforeTax, 1e-9));
    });

    test('chiffre d\'affaires nul : tous les montants sont nuls', () {
      final result = calculateAutoEntrepreneur(
        revenue: 0,
        activity: AutoEntrepreneurActivity.vente,
        versementLiberatoire: true,
      );

      expect(result.socialContributions, 0);
      expect(result.netIncomeBeforeTax, 0);
      expect(result.incomeTaxLiberatoire, 0);
      expect(result.netIncomeAfterTax, 0);
    });
  });
}
