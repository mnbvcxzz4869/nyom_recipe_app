import 'package:flutter/material.dart';
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
    'Noodles',
    'Meat',
    'Seafood',
    'Vegetables',
    'Snacks',
    'Desserts',
  ];

  final List<RecipeDisplayModel> _mockRecipes = [
    const RecipeDisplayModel(
      title: 'Fluffy Strawberry Pancakes',
      timeEstimate: '15',
      category: 'Breakfast',
    ),
    const RecipeDisplayModel(
      title: 'Creamy Garlic Mushroom Pasta',
      timeEstimate: '25',
      category: 'Lunch',
    ),
    const RecipeDisplayModel(
      title: 'Grilled Salmon with Avocado',
      timeEstimate: '30',
      category: 'Dinner',
    ),
    const RecipeDisplayModel(
      title: 'Fresh Green Detox Salad',
      timeEstimate: '10',
      category: 'Healthy',
    ),
  ];

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
          clipBehavior: Clip
              .none, // FIX: Stops CustomScrollView from cutting off bleeding child box-shadows!
          slivers: [
            // --- SEARCH CONTROL ELEMENT HEADER BLOCK ---
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                ), // Adds side padding strictly inside the row item
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16.0),
                    Text(
                      'My Recipes',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 16.0),
                    RecipeSearchBar(controller: _searchController),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16.0)),

            // --- HORIZONTAL FILTER SELECTION SCROLL ROW MODULE ---
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

            // --- NATIVE, PERFECTLY UNIFORM RECIPE GRID VIEW ---
            SliverPadding(
              padding: const EdgeInsets.only(
                left:
                    16.0, // Move horizontal padding here so side cards have shadow buffer room
                right: 16.0,
                top: 16.0,
                bottom: 110.0, // Clearance for your floating bottom bar
              ),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16.0,
                  crossAxisSpacing: 16.0,
                  childAspectRatio: 0.55,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final recipe = _mockRecipes[index % _mockRecipes.length];
                  return RecipeCard(
                    type: RecipeCardType.discoveryGrid,
                    recipe: recipe,
                    onTap: () {
                      debugPrint(
                        'Tapped recipe context profile: ${recipe.title}',
                      );
                    },
                  );
                }, childCount: 8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
