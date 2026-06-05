import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nyom_recipe_app/features/recipes/models/recipe.dart';
import 'package:nyom_recipe_app/features/recipes/providers/recipe_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/recipe_card.dart';
import '../../../shared/widgets/recipe_search_bar.dart';
import '../../../shared/widgets/recipe_filter_chips.dart';

class RecipesScreen extends ConsumerStatefulWidget {
  const RecipesScreen({super.key});

  @override
  ConsumerState<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends ConsumerState<RecipesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Rice',
    'Noodle',
    'Meat',
    'Seafood',
    'Vegetables',
    'Snacks',
    'Desserts',
  ];

  List<Recipe> _applyFilters(List<Recipe> recipes) {
    return recipes.where((recipe) {
      final matchesCategory =
          _selectedCategory == 'All' ||
          recipe.category.name.toLowerCase() == _selectedCategory.toLowerCase();
      final matchesSearch =
          _searchController.text.isEmpty ||
          recipe.title.toLowerCase().contains(
            _searchController.text.toLowerCase(),
          );
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncRecipes = ref.watch(recipesProvider);

    return Scaffold(
      backgroundColor: AppTheme.baseBackground,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          clipBehavior: Clip.none,
          slivers: [
            // ── Header + Search ───────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4.0),
                    Text(
                      'My Recipes',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 16.0),
                    RecipeSearchBar(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16.0)),

            // ── Filter chips ──────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: RecipeFilterChips(
                  categories: _categories,
                  selectedCategory: _selectedCategory,
                  onCategorySelected: (category) {
                    setState(() => _selectedCategory = category);
                  },
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16.0)),

            // ── Body: loading / error / empty / grid ──────────────────
            asyncRecipes.when(
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),

              error: (err, _) => SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: AppTheme.greyAccent,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Failed to load recipes',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => ref.invalidate(recipesProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),

              data: (recipes) {
                final filtered = _applyFilters(recipes);

                if (recipes.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.menu_book_outlined,
                            size: 56,
                            color: AppTheme.greyAccent,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No recipes yet',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tap + to add your first recipe',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppTheme.greyAccent),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (filtered.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.search_off_rounded,
                            size: 56,
                            color: AppTheme.greyAccent,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No matches found',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Try a different search or category',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppTheme.greyAccent),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.only(
                    left: 16.0,
                    right: 16.0,
                    bottom: 110.0,
                  ),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16.0,
                          crossAxisSpacing: 16.0,
                          childAspectRatio: 0.65,
                        ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final recipe = filtered[index];
                      return RecipeCard(
                        type: RecipeCardType.discoveryGrid,
                        recipe: recipe,
                        onTap: () =>
                            context.push('/recipe-detail/${recipe.id}'),
                      );
                    }, childCount: filtered.length),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
