import 'package:flutter/material.dart';
import '../../data/datasources/api_service.dart';

class RecipeProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<dynamic> _recommendations = [];
  Map<String, dynamic> _smartSuggestions = {};
  bool _isLoading = false;

  List<dynamic> get recommendations => _recommendations;
  Map<String, dynamic> get smartSuggestions => _smartSuggestions;
  bool get isLoading => _isLoading;

  Future<void> fetchRecommendations(List<String> ingredients) async {
    // We now allow fetching even if empty to get 'Popular' fallbacks from backend
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _apiService.getRecipeRecommendations(ingredients);
      _recommendations = result['recommendations'] ?? [];
      _smartSuggestions = result['smart_suggestions'] ?? {};
    } catch (e) {
      debugPrint('Error fetching recipes: $e');
      _recommendations = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
