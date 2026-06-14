class GlossaryTerm {
  final String term;
  final String definition;
  final String category;

  const GlossaryTerm({
    required this.term,
    required this.definition,
    required this.category,
  });

  factory GlossaryTerm.fromJson(Map<String, dynamic> json) {
    return GlossaryTerm(
      term: json['term'] as String,
      definition: json['definition'] as String,
      category: json['category'] as String,
    );
  }
}
