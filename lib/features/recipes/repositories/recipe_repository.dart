import 'dart:io';

import 'package:nyom_recipe_app/core/constants/app_constants.dart';
import 'package:nyom_recipe_app/core/errors/app_exceptions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
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
        .insert({...recipe.toJson()..remove('id'), 'user_id': userId})
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

  Future<String> uploadImage(File file) async {
    final fileName = '${const Uuid().v4()}.jpg';
    try {
      await _client.storage
          .from(AppConstants.recipeImagesBucket)
          .upload(fileName, file);
      return _client.storage
          .from(AppConstants.recipeImagesBucket)
          .getPublicUrl(fileName);
    } catch (e) {
      throw ImageUploadException(e.toString());
    }
  }
}
