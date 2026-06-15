/// Catégories d'activité en micro-entreprise (taux de cotisations différents).
enum AutoEntrepreneurActivity { vente, prestationBic, prestationBnc, liberaleReglementee }

/// Taux de cotisations sociales par activité, en fraction du chiffre
/// d'affaires. Valeurs indicatives — à vérifier sur autoentrepreneur.urssaf.fr,
/// elles évoluent régulièrement et dépendent de dispositifs comme l'ACRE.
const Map<AutoEntrepreneurActivity, double> socialContributionRates = {
  AutoEntrepreneurActivity.vente: 0.123,
  AutoEntrepreneurActivity.prestationBic: 0.212,
  AutoEntrepreneurActivity.prestationBnc: 0.211,
  AutoEntrepreneurActivity.liberaleReglementee: 0.212,
};

/// Taux du versement fiscal libératoire de l'impôt sur le revenu (optionnel,
/// sous conditions de revenu fiscal de référence), en fraction du CA.
const Map<AutoEntrepreneurActivity, double> incomeTaxLiberatoireRates = {
  AutoEntrepreneurActivity.vente: 0.01,
  AutoEntrepreneurActivity.prestationBic: 0.017,
  AutoEntrepreneurActivity.prestationBnc: 0.022,
  AutoEntrepreneurActivity.liberaleReglementee: 0.022,
};

class AutoEntrepreneurResult {
  final double socialContributions;
  final double netIncomeBeforeTax;
  final double? incomeTaxLiberatoire;
  final double netIncomeAfterTax;

  const AutoEntrepreneurResult({
    required this.socialContributions,
    required this.netIncomeBeforeTax,
    required this.incomeTaxLiberatoire,
    required this.netIncomeAfterTax,
  });
}

/// Estime les cotisations sociales et le revenu net d'un micro-entrepreneur
/// à partir de son chiffre d'affaires et de son type d'activité.
AutoEntrepreneurResult calculateAutoEntrepreneur({
  required double revenue,
  required AutoEntrepreneurActivity activity,
  required bool versementLiberatoire,
}) {
  final socialContributions = revenue * socialContributionRates[activity]!;
  final netIncomeBeforeTax = revenue - socialContributions;

  final incomeTax = versementLiberatoire ? revenue * incomeTaxLiberatoireRates[activity]! : null;
  final netIncomeAfterTax = netIncomeBeforeTax - (incomeTax ?? 0);

  return AutoEntrepreneurResult(
    socialContributions: socialContributions,
    netIncomeBeforeTax: netIncomeBeforeTax,
    incomeTaxLiberatoire: incomeTax,
    netIncomeAfterTax: netIncomeAfterTax,
  );
}
