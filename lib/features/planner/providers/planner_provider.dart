import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/meal_plan.dart';
import '../repositories/planner_repository.dart';

final plannerRepositoryProvider = Provider((ref) =>
    PlannerRepository(Supabase.instance.client));

final selectedDateProvider =
    NotifierProvider<SelectedDateNotifier, String>(SelectedDateNotifier.new);

class SelectedDateNotifier extends Notifier<String> {
  @override
  String build() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  void setDate(String dateKey) => state = dateKey;
}

final mealPlanProvider =
    AsyncNotifierProvider<MealPlanNotifier, MealPlan>(MealPlanNotifier.new);

class MealPlanNotifier extends AsyncNotifier<MealPlan> {
  @override
  Future<MealPlan> build() {
    final dateKey = ref.watch(selectedDateProvider);
    return ref.read(plannerRepositoryProvider).fetchByDate(dateKey);
  }

  Future<void> addMeal(String mealType, String recipeId) async {
    final dateKey = ref.read(selectedDateProvider);
    await ref.read(plannerRepositoryProvider).addMeal(
          dateKey: dateKey,
          mealType: mealType,
          recipeId: recipeId,
        );
    ref.invalidateSelf();
  }

  Future<void> removeMeal(String mealType, String recipeId) async {
    final dateKey = ref.read(selectedDateProvider);
    await ref.read(plannerRepositoryProvider).removeMeal(
          dateKey: dateKey,
          mealType: mealType,
          recipeId: recipeId,
        );
    ref.invalidateSelf();
  }
}