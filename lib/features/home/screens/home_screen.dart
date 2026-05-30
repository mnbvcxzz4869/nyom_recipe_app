import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:nyom_recipe_app/core/mock/mock_data.dart';
import 'package:nyom_recipe_app/features/grocery/models/grocery_item.dart';
import 'package:nyom_recipe_app/features/planner/models/meal_plan.dart';
import 'package:nyom_recipe_app/features/recipes/models/recipe.dart';
import 'package:nyom_recipe_app/shared/widgets/grocery_checkbox_tile.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/recipe_card.dart';
import '../../../shared/widgets/weekly_calendar_strip.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DateTime _calendarBaseDate = DateTime.now().subtract(
    const Duration(days: 2),
  );
  int _selectedWeekNumber = 1;

  final MealPlan _todayPlan = mockMealPlanForDate(DateTime.now());
  final List<Recipe> _mockRecipesFeed = mockRecipes.take(6).toList();
  final List<GroceryItem> _groceryPreview = mockGroceryItems.take(5).toList();

  String _getCurrentMealSlotByTime() {
    final int currentHour = DateTime.now().hour;
    if (currentHour >= 0 && currentHour < 11) return 'breakfast';
    if (currentHour >= 11 && currentHour < 15) return 'lunch';
    return 'dinner';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.baseBackground,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _buildTodayPlan(),
              const SizedBox(height: 20),
              _buildWeeklyPlanner(),
              const SizedBox(height: 20),
              _buildRecipesSection(context),
              const SizedBox(height: 20),
              _buildGroceryPreview(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final String readableToday = DateFormat(
      'EEEE, d MMM',
    ).format(DateTime.now());
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                readableToday,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.greyAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Hello, Chef! 👋',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ],
          ),
          GestureDetector(
            onTap: () => _showProfileDialog(context),
            child: const CircleAvatar(
              radius: 24,
              backgroundImage: AssetImage('assets/profile-pics.png'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayPlan() {
    final String slot = _getCurrentMealSlotByTime();
    final List<Recipe> meals = slot == 'breakfast'
        ? _todayPlan.breakfast
        : slot == 'lunch'
        ? _todayPlan.lunch
        : _todayPlan.dinner;
    final Recipe? plannedRecipe = meals.isNotEmpty ? meals.first : null;

    // Capitalise first letter for display
    final String slotLabel = slot[0].toUpperCase() + slot.substring(1);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: RecipeCard(
        type: RecipeCardType.heroActive,
        recipe: plannedRecipe,
        slotLabel: slotLabel,
      ),
    );
  }

  Widget _buildWeeklyPlanner() {
    final int totalMeals =
        _todayPlan.breakfast.length +
        _todayPlan.lunch.length +
        _todayPlan.dinner.length;

    final List<({Recipe recipe, String slot})> allMeals = [
      for (final r in _todayPlan.breakfast) (recipe: r, slot: 'Breakfast'),
      for (final r in _todayPlan.lunch) (recipe: r, slot: 'Lunch'),
      for (final r in _todayPlan.dinner) (recipe: r, slot: 'Dinner'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Weekly Planner",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              TextButton(
                onPressed: () => {},
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.tertiary,
                ),
                child: const Text('See more'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.only(
              left: 12,
              right: 12,
              bottom: 4,
              top: 12,
            ),
            decoration: BoxDecoration(
              color: AppTheme.headingGreen,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.warmYellow,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Week $_selectedWeekNumber',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 10,
                          color: AppTheme.headingGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      '$totalMeals Meals Planned',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppTheme.baseBackground,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // --- Calendar strip ---
                WeeklyCalendarStrip.home(
                  baseDate: _calendarBaseDate,
                  activeWeekNumber: _selectedWeekNumber,
                  onWeekChanged: (newWeek) {
                    setState(() => _selectedWeekNumber = newWeek);
                  },
                ),

                // --- Meal cards ---
                if (allMeals.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ...allMeals.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: RecipeCard(
                        type: RecipeCardType.mealPlannerRow,
                        recipe: entry.recipe,
                        slotLabel: entry.slot,
                        onTap: () {
                          context.push('/recipe-detail', extra: recipe);
                        },
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipesSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const double horizontalPadding = 16.0;
    const double crossAxisSpacing = 16.0;
    const int crossAxisCount = 2;
    const double childAspectRatio = 0.65;

    final double cardWidth =
        (screenWidth - (horizontalPadding * 2) - crossAxisSpacing) /
        crossAxisCount;
    final double cardHeight = cardWidth / childAspectRatio;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Recipes", style: Theme.of(context).textTheme.titleMedium),
              TextButton(
                onPressed: () => {},
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.tertiary,
                ),
                child: const Text('See more'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 4.0),
          child: SizedBox(
            height: cardHeight,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              clipBehavior: Clip.none,
              child: Row(
                children: _mockRecipesFeed.map((recipe) {
                  return Container(
                    width: cardWidth,
                    height: cardHeight,
                    margin: const EdgeInsets.only(right: 16.0),
                    child: RecipeCard(
                      type: RecipeCardType.discoveryGrid,
                      recipe: recipe,
                      onTap: () {
                        context.push('/recipe-detail', extra: recipe);
                      },
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

  // At the top of your home screen State class, you need access to the same source.
  // Pull from mockGroceryItems directly, same as GroceryListScreen does:
  final List<GroceryItem> _allGroceryItems = mockGroceryItems.toList();

  Object? get recipe => null;

  // Then your build method:
  Widget _buildGroceryPreview() {
    // Progress calculated from the FULL list — same as GroceryProgressCard
    final int totalItems = _allGroceryItems.length;
    final int boughtItems = _allGroceryItems.where((i) => i.isBought).length;
    final double percentage = totalItems > 0 ? boughtItems / totalItems : 0.0;

    // Only show first 5 items in the preview
    final List<GroceryItem> preview = _allGroceryItems.take(5).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Grocery List", style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Material(
            color: AppTheme.cardWhite,
            elevation: 2,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 16.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$boughtItems of $totalItems Items done',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        '${(percentage * 100).round()}%',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.greyAccent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: percentage,
                      minHeight: 6,
                      backgroundColor: AppTheme.baseBackground,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppTheme.headingGreen,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // --- FIRST 5 ITEMS ---
                  ...List.generate(preview.length, (index) {
                    final item = preview[index];
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GroceryCheckboxTile(
                          title: item.ingredient.name,
                          measurement: item.ingredient.quantity,
                          isChecked: item.isBought,
                          onChanged: (val) {
                            setState(() {
                              item.isBought = val ?? false;
                            });
                          },
                        ),

                        Divider(
                          color: AppTheme.crossedOutGreen,
                          thickness: 1,
                          height: 12,
                        ),
                      ],
                    );
                  }),

                  const SizedBox(height: 10),
                  Center(
                    child: TextButton(
                      onPressed: () => {},
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.tertiary,
                      ),
                      child: const Text('View All'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void _showProfileDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      insetPadding: const EdgeInsets.all(0),
      backgroundColor: AppTheme.cardWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      content: Text(
        "Would you like to log out?",
        style: Theme.of(context).textTheme.titleMedium,
      ),
      actionsPadding: const EdgeInsets.only(right: 16, bottom: 16),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Cancel", style: Theme.of(context).textTheme.bodySmall),
        ),
        TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
          ),
          child: Text("Logout", style: Theme.of(context).textTheme.bodySmall),
        ),
      ],
    ),
  );
}
