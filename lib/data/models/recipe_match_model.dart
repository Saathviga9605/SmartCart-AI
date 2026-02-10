class RecipeMatchModel {
  final String name;
  final String match;
  final List<String> missing;
  final double score;

  RecipeMatchModel({
    required this.name,
    required this.match,
    required this.missing,
    required this.score,
  });

  factory RecipeMatchModel.fromJson(Map<String, dynamic> json) {
    return RecipeMatchModel(
      name: (json['name'] as String?) ?? '',
      match: (json['match'] as String?) ?? '',
      missing: (json['missing'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

