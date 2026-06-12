import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nyom_recipe_app/features/recipes/models/recipe.dart';
import 'package:nyom_recipe_app/shared/widgets/recipe_card/discovery_recipe_card.dart';
import '../../../core/theme/app_theme.dart';

class RecipesFeedSection extends StatelessWidget {
  final List<Recipe> recipes;

  const RecipesFeedSection({super.key, required this.recipes});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const double horizontalPadding = 16.0;
    const double crossAxisSpacing = 16.0;
    const double childAspectRatio = 0.65;

    final double cardWidth =
        (screenWidth - (horizontalPadding * 2) - crossAxisSpacing) / 2;
    final double cardHeight = cardWidth / childAspectRatio;

    final feed = recipes.take(6).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recipes', style: Theme.of(context).textTheme.titleMedium),
              if (recipes.length >= 6) 
                TextButton(
                  onPressed: () => context.go('/recipes'),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.tertiary,
                  ),
                  child: const Text('See more'),
                ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        if (feed.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'No recipes yet. Tap + to add your first one!',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.greyAccent),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 4.0),
            child: SizedBox(
              height: cardHeight,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                clipBehavior: Clip.none,
                child: Row(
                  children: feed.map((recipe) {
                    return Container(
                      width: cardWidth,
                      height: cardHeight,
                      margin: const EdgeInsets.only(right: 16.0),
                      child: DiscoveryRecipeCard(
                        recipe: recipe,
                        onTap: () =>
                            context.push('/recipe-detail/${recipe.id}'),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
