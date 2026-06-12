import 'package:nyom_recipe_app/features/recipes/models/recipe.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/grocery_item.dart';

class GroceryRepository {
  final SupabaseClient _client;
  GroceryRepository(this._client);

  Future<List<GroceryItem>> fetchAll({required String weekKey}) async {
    final userId = _client.auth.currentUser!.id;
    final response = await _client
        .from('grocery_items')
        .select()
        .eq('user_id', userId)
        .or('week_key.eq.$weekKey,week_key.is.null')
        .order('created_at', ascending: true);
    return (response as List).map((e) => GroceryItem.fromJson(e)).toList();
  }

  Future<GroceryItem> add({
    required String name,
    required String quantity,
    String? category,
  }) async {
    final userId = _client.auth.currentUser!.id;
    final response = await _client
        .from('grocery_items')
        .insert({
          'user_id': userId,
          'name': name,
          'quantity': quantity,
          'category': category,
        })
        .select()
        .single();
    return GroceryItem.fromJson(response);
  }

  Future<void> toggleBought(String id, bool isBought) async {
    await _client
        .from('grocery_items')
        .update({'is_bought': isBought})
        .eq('id', id);
  }

  Future<void> delete(String id) async {
    await _client.from('grocery_items').delete().eq('id', id);
  }

  Future<void> clearBought() async {
    final userId = _client.auth.currentUser!.id;
    await _client
        .from('grocery_items')
        .delete()
        .eq('user_id', userId)
        .eq('is_bought', true);
  }

  Future<void> addFromRecipe({
    required Recipe recipe,
    required String weekKey,
  }) async {
    if (recipe.ingredients.isEmpty) return;
    final userId = _client.auth.currentUser!.id;
    final rows = recipe.ingredients
        .map(
          (ing) => {
            'user_id': userId,
            'name': ing.name,
            'quantity': ing.quantity,
            'category': ing.category?.name,
            'recipe_id': recipe.id,
            'week_key': weekKey,
          },
        )
        .toList();
    await _client.from('grocery_items').insert(rows);
  }

  Future<void> removeByRecipe({
    required String recipeId,
    required String weekKey,
  }) async {
    final userId = _client.auth.currentUser!.id;
    await _client
        .from('grocery_items')
        .delete()
        .eq('user_id', userId)
        .eq('recipe_id', recipeId)
        .eq('week_key', weekKey);
  }
}
