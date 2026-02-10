import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // Use 10.0.2.2 for Android Emulator, localhost for iOS/Web
  static String get _baseUrl {
    if (kIsWeb) return 'http://localhost:5000/api';
    // defaultTargetPlatform is safe to use on web, unlike Platform.isAndroid
    if (defaultTargetPlatform == TargetPlatform.android) return 'http://10.0.2.2:5000/api';
    return 'http://127.0.0.1:5000/api';
  }
  
  Future<Map<String, dynamic>> extractIngredients(String text) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/ingredients/extract'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': text}),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return Map<String, dynamic>.from(decoded);
      } else {
        throw Exception('Failed to extract ingredients: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error extracting ingredients: $e');
      // Fallback: Return simple split if backend fails
      return {
        'ingredients': text.split(' and '), // Extremely basic fallback
        'categories': {}
      };
    }
  }

  Future<Map<String, dynamic>> getRecipeRecommendations(List<String> ingredients) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/recipes/recommend'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'ingredients': ingredients,
          'limit': 5
        }),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return Map<String, dynamic>.from(decoded);
      } else {
        throw Exception('Failed to get recommendations: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error getting recommendations: $e');
      return {
        'recommendations': [],
        'smart_suggestions': {}
      };
    }
  }

  Future<List<Map<String, dynamic>>> searchProducts(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/ingredients/search?q=${Uri.encodeComponent(query)}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(decoded['results'] ?? []);
      } else {
        throw Exception('Failed to search products: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error searching products: $e');
      return [];
    }
  }
}
