import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nyom_recipe_app/core/theme/app_theme.dart';
import 'package:nyom_recipe_app/features/recipes/models/recipe.dart';
import 'package:nyom_recipe_app/shared/widgets/custom_button.dart';
import 'package:nyom_recipe_app/shared/widgets/recipe_card/meal_planner_recipe_card.dart';

class MealSlotSection extends StatelessWidget {
  final String label;
  final List<Recipe> recipes;
  final Set<String> dismissed;
  final VoidCallback onAdd;
  final void Function(String recipeId) onDismiss;

  const MealSlotSection({
    super.key,
    required this.label,
    required this.recipes,
    required this.dismissed,
    required this.onAdd,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final visible = recipes.where((r) => !dismissed.contains(r.id)).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.titleMedium),
            TextButton(
              onPressed: onAdd,
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.tertiary,
              ),
              child: const Text('+ Add'),
            ),
          ],
        ),
        const SizedBox(height: 4),
        if (visible.isEmpty)
          CustomButton(
            text: 'No $label planned — tap to add',
            type: CustomButtonType.dashed,
            onPressed: onAdd,
          )
        else
          Column(
            children: visible.map((recipe) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Dismissible(
                  key: ValueKey('${label}_${recipe.id}'),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) => onDismiss(recipe.id),
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: AppTheme.greyAccent.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.delete_outline, color: AppTheme.greyAccent),
                  ),
                  child: MealPlannerRecipeCard(
                    recipe: recipe,
                    onTap: () => context.push('/recipe-detail/${recipe.id}'),
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}