import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/meal_plan.dart';

class PlannerRepository {
  final SupabaseClient _client;
  PlannerRepository(this._client);

  Future<MealPlan> fetchByDate(String dateKey) async {
    final userId = _client.auth.currentUser!.id;
    final response = await _client
        .from('meal_plans')
        .select('*, recipes(*)')
        .eq('user_id', userId)
        .eq('date_key', dateKey);
    return MealPlan.fromRows(dateKey, List<Map<String, dynamic>>.from(response));
  }

  Future<void> addMeal({
    required String dateKey,
    required String mealType,
    required String recipeId,
  }) async {
    final userId = _client.auth.currentUser!.id;
    await _client.from('meal_plans').insert({
      'user_id': userId,
      'date_key': dateKey,
      'meal_type': mealType,
      'recipe_id': recipeId,
    });
  }

  Future<void> removeMeal({
    required String dateKey,
    required String mealType,
    required String recipeId,
  }) async {
    final userId = _client.auth.currentUser!.id;
    await _client
        .from('meal_plans')
        .delete()
        .eq('user_id', userId)
        .eq('date_key', dateKey)
        .eq('meal_type', mealType)
        .eq('recipe_id', recipeId);
  }
}