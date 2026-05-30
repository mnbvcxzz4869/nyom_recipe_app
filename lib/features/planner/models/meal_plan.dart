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

  bool get isEmpty => breakfast.isEmpty && lunch.isEmpty && dinner.isEmpty;
}