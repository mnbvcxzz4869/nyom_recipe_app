import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/meal_plan.dart';
import '../repositories/planner_repository.dart';
import '../../grocery/providers/grocery_provider.dart';
import '../../recipes/providers/recipe_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../shared/utils/week_key.dart';

final plannerRepositoryProvider = Provider(
  (ref) => PlannerRepository(Supabase.instance.client),
);

class SelectedDateNotifier extends StateNotifier<String> {
  SelectedDateNotifier(super.initialDate);
  void setDate(String dateKey) => state = dateKey;
}

String _todayKey() {
  final today = DateTime.now();
  return '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
}

final selectedDateProvider =
    StateNotifierProvider<SelectedDateNotifier, String>(
      (ref) => SelectedDateNotifier(_todayKey()),
    );

final plannerSelectedDateProvider =
    StateNotifierProvider<SelectedDateNotifier, String>(
      (ref) => SelectedDateNotifier(_todayKey()),
    );

final todayMealPlanProvider = FutureProvider<MealPlan>((ref) {
  ref.watch(currentUserIdProvider);
  return ref.read(plannerRepositoryProvider).fetchByDate(_todayKey());
});

final mealPlanProvider = AsyncNotifierProvider<MealPlanNotifier, MealPlan>(
  MealPlanNotifier.new,
);

class MealPlanNotifier extends AsyncNotifier<MealPlan> {
  @override
  Future<MealPlan> build() {
    ref.watch(currentUserIdProvider);
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
    ref.invalidate(mealPlanProvider);
    try {
      final recipe = await ref
          .read(recipeRepositoryProvider)
          .fetchById(recipeId);
      await ref
          .read(groceryProvider.notifier)
          .addFromRecipe(recipe: recipe, weekKey: isoWeekKey(dateKey));
    } catch (e) {
      debugPrint('Grocery sync failed: $e');
    }
  }

  Future<void> removeMeal(String mealType, String recipeId) async {
    final dateKey = ref.read(selectedDateProvider);
    await ref
        .read(plannerRepositoryProvider)
        .removeMeal(dateKey: dateKey, mealType: mealType, recipeId: recipeId);
    ref.invalidateSelf();
    ref.invalidate(todayMealPlanProvider);
    ref.invalidate(mealPlanProvider);
    try {
      await ref
          .read(groceryProvider.notifier)
          .removeByRecipe(recipeId: recipeId, weekKey: isoWeekKey(dateKey));
    } catch (e) {
      debugPrint('Grocery sync failed: $e');
    }
  }
}

final plannerMealPlanProvider =
    AsyncNotifierProvider<PlannerMealPlanNotifier, MealPlan>(
      PlannerMealPlanNotifier.new,
    );

class PlannerMealPlanNotifier extends AsyncNotifier<MealPlan> {
  @override
  Future<MealPlan> build() {
    ref.watch(currentUserIdProvider);
    final dateKey = ref.watch(plannerSelectedDateProvider);
    return ref.read(plannerRepositoryProvider).fetchByDate(dateKey);
  }

  Future<void> addMeal(String mealType, String recipeId) async {
    final dateKey = ref.read(plannerSelectedDateProvider);
    await ref
        .read(plannerRepositoryProvider)
        .addMeal(dateKey: dateKey, mealType: mealType, recipeId: recipeId);
    ref.invalidateSelf();
    ref.invalidate(todayMealPlanProvider);
    ref.invalidate(mealPlanProvider);
    try {
      final recipe = await ref
          .read(recipeRepositoryProvider)
          .fetchById(recipeId);
      await ref
          .read(groceryProvider.notifier)
          .addFromRecipe(recipe: recipe, weekKey: isoWeekKey(dateKey));
    } catch (e) {
      debugPrint('Grocery sync failed: $e');
    }
  }

  Future<void> removeMeal(String mealType, String recipeId) async {
    final dateKey = ref.read(plannerSelectedDateProvider);
    await ref
        .read(plannerRepositoryProvider)
        .removeMeal(dateKey: dateKey, mealType: mealType, recipeId: recipeId);
    ref.invalidateSelf();
    ref.invalidate(todayMealPlanProvider);
    ref.invalidate(mealPlanProvider);
    try {
      await ref
          .read(groceryProvider.notifier)
          .removeByRecipe(recipeId: recipeId, weekKey: isoWeekKey(dateKey));
    } catch (e) {
      debugPrint('Grocery sync failed: $e');
    }
  }
}