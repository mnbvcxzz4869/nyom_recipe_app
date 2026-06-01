import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/meal_plan.dart';
import '../repositories/planner_repository.dart';
import '../../grocery/providers/grocery_provider.dart';
import '../../recipes/providers/recipe_provider.dart';
import '../../../shared/utils/week_key.dart';

final plannerRepositoryProvider = Provider(
  (ref) => PlannerRepository(Supabase.instance.client),
);

final selectedDateProvider = NotifierProvider<SelectedDateNotifier, String>(
  SelectedDateNotifier.new,
);

class SelectedDateNotifier extends Notifier<String> {
  @override
  String build() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  void setDate(String dateKey) => state = dateKey;
}

// Always fetches today's plan — used by HomeScreen so it's never affected
// by the selected date changing in the Weekly Planner calendar.
final todayMealPlanProvider = FutureProvider<MealPlan>((ref) {
  final now = DateTime.now();
  final todayKey =
      '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  return ref.read(plannerRepositoryProvider).fetchByDate(todayKey);
});

final mealPlanProvider = AsyncNotifierProvider<MealPlanNotifier, MealPlan>(
  MealPlanNotifier.new,
);

class MealPlanNotifier extends AsyncNotifier<MealPlan> {
  @override
  Future<MealPlan> build() {
    final dateKey = ref.watch(selectedDateProvider);
    return ref.read(plannerRepositoryProvider).fetchByDate(dateKey);
  }

  Future<void> addMeal(String mealType, String recipeId) async {
    final dateKey = ref.read(selectedDateProvider);
    await ref
        .read(plannerRepositoryProvider)
        .addMeal(dateKey: dateKey, mealType: mealType, recipeId: recipeId);
    ref.invalidateSelf();
    ref.invalidate(todayMealPlanProvider);
    // Auto-populate grocery list — failure must not crash the meal plan op.
    try {
      final recipe = await ref
          .read(recipeRepositoryProvider)
          .fetchById(recipeId);
      await ref
          .read(groceryProvider.notifier)
          .addFromRecipe(recipe: recipe, weekKey: isoWeekKey(dateKey));
    } catch (_) {}
  }

  Future<void> removeMeal(String mealType, String recipeId) async {
    final dateKey = ref.read(selectedDateProvider);
    await ref
        .read(plannerRepositoryProvider)
        .removeMeal(dateKey: dateKey, mealType: mealType, recipeId: recipeId);
    ref.invalidateSelf();
    ref.invalidate(todayMealPlanProvider);
    // Auto-remove grocery items for this recipe/week — failure must not crash.
    try {
      await ref
          .read(groceryProvider.notifier)
          .removeByRecipe(recipeId: recipeId, weekKey: isoWeekKey(dateKey));
    } catch (_) {}
  }
}
