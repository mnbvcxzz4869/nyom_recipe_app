import 'package:flutter/material.dart';
import 'package:nyom_recipe_app/features/grocery/widgets/grocery_category_card.dart';
import '../../../core/theme/app_theme.dart';
import '../../grocery/models/grocery_item.dart';
import '../models/recipe.dart';
import '../models/ingredient_item.dart';

class RecipeDetailScreen extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    // Transform standalone dynamic list entities into clean category card components
    final Map<String, List<GroceryItem>> groupedIngredients = {};
    for (var ing in recipe.ingredients) {
      final categoryLabel = ing.category?.label ?? 'Other';
      groupedIngredients
          .putIfAbsent(categoryLabel, () => [])
          .add(GroceryItem(ingredient: ing));
    }

    return Scaffold(
      backgroundColor: AppTheme.baseBackground,
      body: CustomScrollView(
        slivers: [
          // Hero Floating Image Header
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            stretch: true,
            backgroundColor: AppTheme.headingGreen,
            foregroundColor: AppTheme.cardWhite,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: AppTheme.cardWhite.withValues(alpha: 0.9),
                foregroundColor: AppTheme.headingGreen,
                child: const BackButton(),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: recipe.imageUrl != null
                  ? Image.network(recipe.imageUrl!, fit: BoxFit.cover)
                  : Container(
                      color: AppTheme.headingGreen,
                      child: const Center(
                        child: Icon(
                          Icons.restaurant_menu_rounded,
                          size: 64,
                          color: AppTheme.warmYellow,
                        ),
                      ),
                    ),
            ),
          ),

          // Core Recipe Information Body Layout
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Block Layout
                  Text(
                    recipe.title,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 12),

                  // Metadata Detail Row Chips
                  Row(
                    children: [
                      _buildInlineInfoChip(
                        context,
                        Icons.access_time_rounded,
                        '${recipe.durationMinutes} Mins',
                      ),
                      const SizedBox(width: 12),
                      _buildInlineInfoChip(
                        context,
                        Icons.layers_rounded,
                        recipe.category.label,
                      ),
                    ],
                  ),
                  const Divider(
                    height: 36,
                    thickness: 1,
                    color: AppTheme.greyAccent,
                  ),

                  // Section Title: Component Matrix
                  Text(
                    'Ingredients Required',
                    style: Theme.of(
                      context,
                    ).textTheme.headlineMedium?.copyWith(fontSize: 22),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          // Render structured category breakdown cards
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                groupedIngredients.keys.map((category) {
                  return GroceryCategoryCard(
                    categoryHeading: category,
                    items: groupedIngredients[category]!,
                    type: IngredientListType
                        .recipeView, // Sets circle-bullet item modes
                  );
                }).toList(),
              ),
            ),
          ),

          // Section Title: Preparation Steps
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
              child: Text(
                'Preparation Steps',
                style: Theme.of(
                  context,
                ).textTheme.headlineMedium?.copyWith(fontSize: 22),
              ),
            ),
          ),

          // Ordered Direction Blocks Checklist
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 120.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final stepText = recipe.steps[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Circle Indicator Number Profile
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        height: 24,
                        width: 24,
                        decoration: const BoxDecoration(
                          color: AppTheme.warmYellow,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.headingGreen,
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      // Direction content line wrapping panel
                      Expanded(
                        child: Text(
                          stepText,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(height: 1.4),
                        ),
                      ),
                    ],
                  ),
                );
              }, childCount: recipe.steps.length),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInlineInfoChip(
    BuildContext context,
    IconData icon,
    String detailText,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.greyAccent.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppTheme.headingGreen),
          const SizedBox(width: 6),
          Text(
            detailText,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
