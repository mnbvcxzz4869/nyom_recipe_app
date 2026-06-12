import 'dart:convert';
import '../errors/app_exceptions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/recipes/models/recipe.dart';
import '../../features/recipes/models/ingredient_item.dart';

class GeminiService {
  final SupabaseClient _client;
  GeminiService(this._client);

  Future<Recipe> parseFromText(String text) async {
    return _callParseFunction(mode: 'text', input: text);
  }

  Future<Recipe> parseFromUrl(String url) async {
    return _callParseFunction(mode: 'url', input: url);
  }

  Future<Recipe> _callParseFunction({
    required String mode,
    required String input,
  }) async {
    final response = await _client.functions.invoke(
      'parse-recipe',
      body: {'mode': mode, 'input': input},
    );

    if (response.status != 200) {
      throw RecipeParseException('${response.data}');
    }

    final data = response.data as Map<String, dynamic>;

    // Build ingredient items from Gemini response
    final ingredients = (data['ingredients'] as List<dynamic>? ?? [])
        .map((e) => IngredientItem.fromJson(e as Map<String, dynamic>))
        .toList();

    return Recipe(
      id: '',
      title: data['title'] as String,
      durationMinutes: data['duration_minutes'] as int,
      imageUrl: data['image_url'] as String?,
      category: Category.values.byName(
        (data['category'] as String).toLowerCase(),
      ),
      ingredients: ingredients,
      steps: List<String>.from(data['steps'] ?? []),
    );
  }

  Future<Map<String, String>> categorizeIngredients(List<String> names) async {
    final response = await _client.functions.invoke(
      'parse-recipe',
      body: {'mode': 'categorize', 'input': jsonEncode(names)},
    );

    if (response.status != 200) {
      throw IngredientCategorizationException('status ${response.status}');
    }

    final data = response.data as Map<String, dynamic>;
    return data.map(
      (key, value) => MapEntry(key, value?.toString() ?? 'pantry'),
    );
  }
}
