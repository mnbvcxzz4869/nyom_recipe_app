import 'package:flutter/material.dart';
import 'package:nyom_recipe_app/core/theme/app_theme.dart';
import 'package:nyom_recipe_app/features/recipes/models/recipe.dart';
import 'package:nyom_recipe_app/shared/widgets/recipe_card/meal_planner_recipe_card.dart';
import 'package:nyom_recipe_app/shared/widgets/recipe_search_bar.dart';

class RecipePickerSheet extends StatefulWidget {
  final List<Recipe> recipes;
  const RecipePickerSheet({super.key, required this.recipes});

  @override
  State<RecipePickerSheet> createState() => RecipePickerSheetState();
}

class RecipePickerSheetState extends State<RecipePickerSheet> {
  final TextEditingController _search = TextEditingController();

  List<Recipe> get _filtered {
    if (_search.text.isEmpty) return widget.recipes;
    return widget.recipes
        .where((r) => r.title.toLowerCase().contains(_search.text.toLowerCase()))
        .toList();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.baseBackground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 16),
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.greyAccent.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pick a Recipe', style: Theme.of(context).textTheme.headlineLarge),
                    const SizedBox(height: 12),
                    RecipeSearchBar(
                      controller: _search,
                      hintText: 'Search recipes...',
                      onChanged: (_) => setState(() {}),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _filtered.isEmpty
                    ? Center(
                        child: Text(
                          'No recipes match',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppTheme.greyAccent),
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                        itemCount: _filtered.length,
                        itemBuilder: (context, index) {
                          final recipe = _filtered[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: MealPlannerRecipeCard(
                              recipe: recipe,
                              onTap: () => Navigator.pop(context, recipe),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}