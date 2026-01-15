import 'category_model.dart';

/// Suggestion model for ML-based recommendations
/// Represents a smart suggestion based on user patterns
class SuggestionModel {
  final String itemName;
  final GroceryCategory category;
  final double confidence;
  final List<String> relatedItems;
  final String reason;

  SuggestionModel({
    required this.itemName,
    required this.category,
    required this.confidence,
    this.relatedItems = const [],
    this.reason = '',
  });

  /// Create from JSON (for API responses)
  factory SuggestionModel.fromJson(Map<String, dynamic> json) {
    return SuggestionModel(
      itemName: json['itemName'] as String,
      category: GroceryCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => GroceryCategory.other,
      ),
      confidence: (json['confidence'] as num).toDouble(),
      relatedItems: (json['relatedItems'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      reason: json['reason'] as String? ?? '',
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'itemName': itemName,
      'category': category.name,
      'confidence': confidence,
      'relatedItems': relatedItems,
      'reason': reason,
    };
  }

  /// Check if suggestion is high confidence
  bool get isHighConfidence => confidence >= 0.7;

  @override
  String toString() {
    return 'SuggestionModel(itemName: $itemName, confidence: ${(confidence * 100).toStringAsFixed(0)}%)';
  }
}
