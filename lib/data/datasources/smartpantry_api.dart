import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/constants/api_constants.dart';
import '../models/recipe_match_model.dart';

class SmartPantryApi {
  SmartPantryApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<RecipeMatchModel>> getRecipes(List<String> ingredients) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/recipes/recommend');
    final response = await _client.post(
      uri,
      headers: {'content-type': 'application/json'},
      body: jsonEncode({'ingredients': ingredients}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('get-recipes failed: ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    final top = (data['top_5'] as List<dynamic>? ?? const []);
    return top.whereType<Map>().map((e) {
      return RecipeMatchModel.fromJson(Map<String, dynamic>.from(e));
    }).toList();
  }

  Future<Map<String, dynamic>> recommendMore({
    required List<String> ingredients,
    required List<String> missing,
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/recipes/recommend');
    final response = await _client.post(
      uri,
      headers: {'content-type': 'application/json'},
      body: jsonEncode({'ingredients': ingredients, 'missing': missing}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('recommend-more failed: ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    if (data is Map<String, dynamic>) {
      return data;
    }
    return {};
  }

  Future<void> sendFeedback({
    String? userId,
    required String recipeName,
    required String action,
    Map<String, dynamic>? context,
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/feedback');
    final response = await _client.post(
      uri,
      headers: {'content-type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'recipe_name': recipeName,
        'action': action,
        'context': context ?? const {},
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('feedback failed: ${response.statusCode}');
    }
  }
}
