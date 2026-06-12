import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nyom_recipe_app/features/planner/models/meal_plan.dart';
import 'package:nyom_recipe_app/features/recipes/models/recipe.dart';
import 'package:nyom_recipe_app/shared/widgets/recipe_card/hero_recipe_card.dart';

class TodayPlanCard extends StatelessWidget {
  final MealPlan? plan;

  const TodayPlanCard({super.key, this.plan});

  String _getCurrentMealSlotByTime() {
    final int h = DateTime.now().hour;
    if (h < 11) return 'breakfast';
    if (h < 15) return 'lunch';
    return 'dinner';
  }

  @override
  Widget build(BuildContext context) {
    final slot = _getCurrentMealSlotByTime();
    final List<Recipe> meals = plan == null
        ? []
        : slot == 'breakfast'
            ? plan!.breakfast
            : slot == 'lunch'
                ? plan!.lunch
                : plan!.dinner;
    final Recipe? plannedRecipe = meals.isNotEmpty ? meals.first : null;
    final slotLabel = slot[0].toUpperCase() + slot.substring(1);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: HeroRecipeCard(
        recipe: plannedRecipe,
        slotLabel: slotLabel,
        onTap: plannedRecipe != null
            ? () => context.push('/recipe-detail/${plannedRecipe.id}')
            : null,
      ),
    );
  }
}