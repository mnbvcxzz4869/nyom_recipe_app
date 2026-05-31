import 'package:nyom_recipe_app/features/recipes/models/recipe.dart';

class MealPlan {
  final String dateKey;
  final List<Recipe> breakfast;
  final List<Recipe> lunch;
  final List<Recipe> dinner;

  const MealPlan({
    required this.dateKey,
    this.breakfast = const [],
    this.lunch = const [],
    this.dinner = const [],
  });

  // Builds a MealPlan from a list of DB rows for a given date
  factory MealPlan.fromRows(String dateKey, List<Map<String, dynamic>> rows) {
    final breakfast = <Recipe>[];
    final lunch = <Recipe>[];
    final dinner = <Recipe>[];

    for (final row in rows) {
      final recipe = Recipe.fromJson(row['recipes'] as Map<String, dynamic>);
      final mealType = (row['meal_type'] as String).toLowerCase();
      if (mealType == 'breakfast') breakfast.add(recipe);
      else if (mealType == 'lunch') lunch.add(recipe);
      else if (mealType == 'dinner') dinner.add(recipe);
    }

    return MealPlan(
      dateKey: dateKey,
      breakfast: breakfast,
      lunch: lunch,
      dinner: dinner,
    );
  }

  bool get isEmpty => breakfast.isEmpty && lunch.isEmpty && dinner.isEmpty;
}