class MarketPoint {
  final int year;
  final double value;

  const MarketPoint({required this.year, required this.value});

  factory MarketPoint.fromJson(Map<String, dynamic> json) {
    return MarketPoint(
      year: json['year'] as int,
      value: (json['value'] as num).toDouble(),
    );
  }
}

class BusinessIdea {
  final String id;
  final String title;
  final String category;
  final String icon;
  final String pitch;
  final String description;
  final String difficulty;
  final int investmentMin;
  final int investmentMax;
  final int timeToProfitMonths;
  final String marketSizeLabel;
  final double growthRatePercent;
  final String marketTrendUnit;
  final List<MarketPoint> marketTrend;
  final String targetAudience;
  final List<String> pros;
  final List<String> cons;
  final List<String> firstSteps;
  final List<String> skillsNeeded;

  const BusinessIdea({
    required this.id,
    required this.title,
    required this.category,
    required this.icon,
    required this.pitch,
    required this.description,
    required this.difficulty,
    required this.investmentMin,
    required this.investmentMax,
    required this.timeToProfitMonths,
    required this.marketSizeLabel,
    required this.growthRatePercent,
    required this.marketTrendUnit,
    required this.marketTrend,
    required this.targetAudience,
    required this.pros,
    required this.cons,
    required this.firstSteps,
    required this.skillsNeeded,
  });

  factory BusinessIdea.fromJson(Map<String, dynamic> json) {
    return BusinessIdea(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      icon: json['icon'] as String,
      pitch: json['pitch'] as String,
      description: json['description'] as String,
      difficulty: json['difficulty'] as String,
      investmentMin: json['investmentMin'] as int,
      investmentMax: json['investmentMax'] as int,
      timeToProfitMonths: json['timeToProfitMonths'] as int,
      marketSizeLabel: json['marketSizeLabel'] as String,
      growthRatePercent: (json['growthRatePercent'] as num).toDouble(),
      marketTrendUnit: json['marketTrendUnit'] as String,
      marketTrend: (json['marketTrend'] as List)
          .map((e) => MarketPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      targetAudience: json['targetAudience'] as String,
      pros: (json['pros'] as List).cast<String>(),
      cons: (json['cons'] as List).cast<String>(),
      firstSteps: (json['firstSteps'] as List).cast<String>(),
      skillsNeeded: (json['skillsNeeded'] as List).cast<String>(),
    );
  }
}
