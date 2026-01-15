import 'package:flutter/foundation.dart';
import '../../data/models/category_model.dart';
import '../../data/models/suggestion_model.dart';

/// Provider for ML-based inference and predictions
/// Handles on-device category classification using TFLite
class MLInferenceProvider with ChangeNotifier {
  bool _isModelLoaded = false;
  bool _isInferring = false;

  // Getters
  bool get isModelLoaded => _isModelLoaded;
  bool get isInferring => _isInferring;

  /// Initialize and load TFLite model
  /// In a production app, this would load the actual .tflite model
  Future<void> loadModel() async {
    try {
      _isInferring = true;
      notifyListeners();

      // Placeholder for TFLite model loading
      // In production:
      // await Tflite.loadModel(
      //   model: 'assets/ml_models/category_classifier.tflite',
      //   labels: 'assets/ml_models/labels.txt',
      // );

      // Simulate loading delay
      await Future.delayed(const Duration(milliseconds: 500));

      _isModelLoaded = true;
      debugPrint('ML Model loaded successfully');
    } catch (e) {
      debugPrint('Error loading ML model: $e');
      _isModelLoaded = false;
    } finally {
      _isInferring = false;
      notifyListeners();
    }
  }

  /// Predict category for a grocery item
  /// Uses simple keyword matching as placeholder for ML inference
  Future<GroceryCategory> predictCategory(String itemName) async {
    if (!_isModelLoaded) {
      await loadModel();
    }

    _isInferring = true;
    notifyListeners();

    try {
      // Placeholder ML inference using keyword matching
      // In production, this would use TFLite model inference
      final category = _keywordBasedCategorization(itemName);

      await Future.delayed(const Duration(milliseconds: 100));

      return category;
    } finally {
      _isInferring = false;
      notifyListeners();
    }
  }

  /// Get smart suggestions based on current items
  /// Placeholder for collaborative filtering / pattern recognition
  Future<List<SuggestionModel>> getSuggestions(
    List<String> currentItems,
  ) async {
    // Placeholder suggestions
    // In production, this would analyze purchase history and patterns
    final suggestions = <SuggestionModel>[];

    // Simple rule-based suggestions
    if (currentItems.any((item) => item.toLowerCase().contains('milk'))) {
      suggestions.add(SuggestionModel(
        itemName: 'Bread',
        category: GroceryCategory.bakery,
        confidence: 0.85,
        relatedItems: ['Milk'],
        reason: 'Often bought together',
      ));
    }

    if (currentItems.any((item) => item.toLowerCase().contains('pasta'))) {
      suggestions.add(SuggestionModel(
        itemName: 'Tomato Sauce',
        category: GroceryCategory.other,
        confidence: 0.90,
        relatedItems: ['Pasta'],
        reason: 'Frequently purchased with pasta',
      ));
    }

    return suggestions;
  }

  /// Keyword-based categorization (placeholder for ML model)
  /// In production, this would be replaced with TFLite inference
  GroceryCategory _keywordBasedCategorization(String itemName) {
    final name = itemName.toLowerCase();

    // Fruits
    if (_containsAny(name, [
      'apple',
      'banana',
      'orange',
      'grape',
      'mango',
      'strawberry',
      'watermelon',
      'pear',
      'peach',
      'cherry'
    ])) {
      return GroceryCategory.fruits;
    }

    // Vegetables
    if (_containsAny(name, [
      'carrot',
      'potato',
      'tomato',
      'onion',
      'lettuce',
      'spinach',
      'broccoli',
      'cucumber',
      'pepper',
      'cabbage'
    ])) {
      return GroceryCategory.vegetables;
    }

    // Dairy
    if (_containsAny(name, [
      'milk',
      'cheese',
      'yogurt',
      'butter',
      'cream',
      'ice cream',
      'eggs'
    ])) {
      return GroceryCategory.dairy;
    }

    // Meat
    if (_containsAny(name, [
      'chicken',
      'beef',
      'pork',
      'fish',
      'salmon',
      'turkey',
      'lamb',
      'shrimp',
      'meat'
    ])) {
      return GroceryCategory.meat;
    }

    // Bakery
    if (_containsAny(name, [
      'bread',
      'baguette',
      'croissant',
      'muffin',
      'bagel',
      'donut',
      'cake',
      'pastry'
    ])) {
      return GroceryCategory.bakery;
    }

    // Beverages
    if (_containsAny(name, [
      'coffee',
      'tea',
      'juice',
      'soda',
      'water',
      'beer',
      'wine',
      'drink'
    ])) {
      return GroceryCategory.beverages;
    }

    // Snacks
    if (_containsAny(name, [
      'chips',
      'cookie',
      'chocolate',
      'candy',
      'popcorn',
      'nuts',
      'crackers',
      'snack'
    ])) {
      return GroceryCategory.snacks;
    }

    return GroceryCategory.other;
  }

  /// Helper to check if string contains any of the keywords
  bool _containsAny(String text, List<String> keywords) {
    return keywords.any((keyword) => text.contains(keyword));
  }

  /// Dispose and cleanup
  @override
  void dispose() {
    // In production, close TFLite model
    // Tflite.close();
    super.dispose();
  }
}
