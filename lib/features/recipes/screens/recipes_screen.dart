import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nyom_recipe_app/core/mock/mock_data.dart';
import 'package:nyom_recipe_app/features/recipes/models/recipe.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/recipe_card.dart';
import '../../../shared/widgets/recipe_search_bar.dart';
import '../../../shared/widgets/recipe_filter_chips.dart';

class RecipesScreen extends StatefulWidget {
  const RecipesScreen({super.key});

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
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

  final List<Recipe> _mockRecipes = mockRecipes;

  List<Recipe> get _filteredRecipes {
    return _mockRecipes.where((recipe) {
      final matchesCategory = _selectedCategory == 'All' ||
          recipe.category.name.toLowerCase() ==
              _selectedCategory.toLowerCase();
      final matchesSearch = _searchController.text.isEmpty ||
          recipe.title
              .toLowerCase()
              .contains(_searchController.text.toLowerCase());
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
    return Scaffold(
      backgroundColor: AppTheme.baseBackground,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          clipBehavior: Clip.none,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16.0),
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

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: RecipeFilterChips(
                  categories: _categories,
                  selectedCategory: _selectedCategory,
                  onCategorySelected: (category) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                top: 16.0,
                bottom: 110.0,
              ),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16.0,
                  crossAxisSpacing: 16.0,
                  childAspectRatio: 0.65,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final recipe = _filteredRecipes[index];
                    return RecipeCard(
                      type: RecipeCardType.discoveryGrid,
                      recipe: recipe,
                      onTap: () {
                        context.push('/recipe-detail', extra: recipe);
                      },
                    );
                  },
                  childCount: _filteredRecipes.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}