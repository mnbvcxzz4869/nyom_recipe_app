import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/recipe.dart';

class RecipeRepository {
  final SupabaseClient _client;
  RecipeRepository(this._client);

  Future<List<Recipe>> fetchAll() async {
    final response = await _client
        .from('recipes')
        .select()
        .order('created_at', ascending: false);
    return (response as List).map((e) => Recipe.fromJson(e)).toList();
  }

  Future<Recipe> fetchById(String id) async {
    final response = await _client
        .from('recipes')
        .select()
        .eq('id', id)
        .single();
    return Recipe.fromJson(response);
  }

  Future<Recipe> create(Recipe recipe) async {
    final userId = _client.auth.currentUser!.id;
    final response = await _client
        .from('recipes')
        .insert({
          ...recipe.toJson()..remove('id'),
          'user_id': userId,
        })
        .select()
        .single();
    return Recipe.fromJson(response);
  }

  Future<Recipe> update(Recipe recipe) async {
    final response = await _client
        .from('recipes')
        .update(recipe.toJson())
        .eq('id', recipe.id)
        .select()
        .single();
    return Recipe.fromJson(response);
  }

  Future<void> delete(String id) async {
    await _client.from('recipes').delete().eq('id', id);
  }
}