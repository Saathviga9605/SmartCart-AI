import 'package:flutter/foundation.dart';

import '../../data/datasources/smartpantry_api.dart';
import '../../data/models/category_model.dart';
import '../../data/models/recipe_match_model.dart';
import '../../data/models/suggestion_model.dart';

class SmartPantryProvider with ChangeNotifier {
  SmartPantryProvider({SmartPantryApi? api}) : _api = api ?? SmartPantryApi();

  final SmartPantryApi _api;

  bool _isLoading = false;
  String? _error;
  List<RecipeMatchModel> _recipes = [];
  List<SuggestionModel> _suggestions = [];
  Map<String, List<String>> _substitutes = {};

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<RecipeMatchModel> get recipes => _recipes;
  List<SuggestionModel> get suggestions => _suggestions;
  Map<String, List<String>> get substitutes => _substitutes;

  Future<void> refreshFromIngredients(List<String> ingredients) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final normalized = ingredients.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      final recipes = await _api.getRecipes(normalized);
      _recipes = recipes;

      final missing = recipes.isNotEmpty ? recipes.first.missing : <String>[];
      final more = await _api.recommendMore(ingredients: normalized, missing: missing);
      _substitutes = _parseSubstitutes(more['substitutes']);
      _suggestions = _extrasToSuggestions(more['extra_suggestions']);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendRecipeFeedback({
    String? userId,
    required String recipeName,
    required bool liked,
    List<String> ingredients = const [],
  }) async {
    await _api.sendFeedback(
      userId: userId,
      recipeName: recipeName,
      action: liked ? 'liked' : 'disliked',
      context: {'ingredients': ingredients},
    );
  }

  Map<String, List<String>> _parseSubstitutes(dynamic raw) {
    if (raw is! Map) return {};
    final out = <String, List<String>>{};
    raw.forEach((key, value) {
      final k = key.toString();
      if (value is List) {
        out[k] = value.map((e) => e.toString()).toList();
      }
    });
    return out;
  }

  List<SuggestionModel> _extrasToSuggestions(dynamic raw) {
    if (raw is! List) return [];
    return raw.map((e) {
      if (e is Map) {
        final categoryStr = (e['category'] as String?)?.toLowerCase() ?? '';
        final category = GroceryCategory.values.firstWhere(
          (c) => c.name.toLowerCase() == categoryStr,
          orElse: () => GroceryCategory.other,
        );
        
        return SuggestionModel(
          itemName: (e['item_name'] as String?) ?? 'Unknown',
          category: category,
          confidence: (e['confidence'] as num?)?.toDouble() ?? 0.8,
          relatedItems: (e['related_items'] as List?)?.map((i) => i.toString()).toList() ?? const [],
          reason: (e['reason'] as String?) ?? 'Recommended',
        );
      }
      // Fallback for string list
      return SuggestionModel(
        itemName: e.toString(),
        category: GroceryCategory.other,
        confidence: 0.8,
        relatedItems: const [],
        reason: 'Recommended',
      );
    }).where((s) => s.itemName.isNotEmpty).toList();
  }
}

