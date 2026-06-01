import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:nyom_recipe_app/features/auth/providers/auth_provider.dart';
import 'package:nyom_recipe_app/features/auth/providers/auth_provider.dart';
import 'package:nyom_recipe_app/features/grocery/models/grocery_item.dart';
import 'package:nyom_recipe_app/features/grocery/providers/grocery_provider.dart';
import 'package:nyom_recipe_app/features/planner/models/meal_plan.dart';
import 'package:nyom_recipe_app/features/planner/providers/planner_provider.dart';
import 'package:nyom_recipe_app/features/recipes/models/recipe.dart';
import 'package:nyom_recipe_app/features/recipes/providers/recipe_provider.dart';
import 'package:nyom_recipe_app/shared/widgets/grocery_checkbox_tile.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/recipe_card.dart';
import '../../../shared/widgets/weekly_calendar_strip.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // baseDate comes from the user's signup date so week numbers are consistent.
  DateTime get _calendarBaseDate {
    final signupDate = ref.watch(userCreatedAtProvider).value;
    final anchor = signupDate ?? DateTime.now();
    return anchor.subtract(Duration(days: anchor.weekday - 1));
  }

  int _selectedWeekNumber = 1;

  String _getCurrentMealSlotByTime() {
    final int h = DateTime.now().hour;
    if (h < 11) return 'breakfast';
    if (h < 15) return 'lunch';
    return 'dinner';
  }

  @override
  Widget build(BuildContext context) {
    // todayMealPlanProvider is always pinned to today — never affected by
    // the calendar date selection. Use valueOrNull so switching dates doesn't
    // flash a loading spinner; the previous data stays visible while refreshing.
    final todayPlan = ref.watch(todayMealPlanProvider).value;
    final recipesAsync = ref.watch(recipesProvider);
    final groceryAsync = ref.watch(groceryProvider);

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

              // ── Today's hero card ──────────────────────────────────────
              _buildTodayPlan(todayPlan),
              const SizedBox(height: 20),

              // ── Weekly planner summary ─────────────────────────────────
              _buildWeeklyPlanner(todayPlan),
              const SizedBox(height: 20),

              // ── Recipes feed ───────────────────────────────────────────
              recipesAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: SizedBox(
                    height: 80,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
                error: (_, __) => const SizedBox.shrink(),
                data: (recipes) => _buildRecipesSection(context, recipes),
              ),
              const SizedBox(height: 20),

              // ── Grocery preview ────────────────────────────────────────
              groceryAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (items) => _buildGroceryPreview(items),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    final String readableToday = DateFormat(
      'EEEE, d MMM',
    ).format(DateTime.now());
    final currentUserAsync = ref.watch(currentUserProvider);

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
              currentUserAsync.when(
                data: (user) => Text(
                  'Hello, ${user?.username ?? 'Chef'}! 👋',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                loading: () => Text(
                  'Hello! 👋',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                error: (_, __) => Text(
                  'Hello, Chef! 👋',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () => _showProfileDialog(context, ref),
            child: currentUserAsync.when(
              data: (user) => CircleAvatar(
                radius: 24,
                backgroundImage: user?.avatarUrl != null
                    ? NetworkImage(user!.avatarUrl!) as ImageProvider
                    : const AssetImage('assets/profile-pics.png'),
              ),
              loading: () => const CircleAvatar(
                radius: 24,
                backgroundImage: AssetImage('assets/profile-pics.png'),
              ),
              error: (_, __) => const CircleAvatar(
                radius: 24,
                backgroundImage: AssetImage('assets/profile-pics.png'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Today's hero card ───────────────────────────────────────────────────────

  Widget _buildTodayPlan(MealPlan? plan) {
    final String slot = _getCurrentMealSlotByTime();
    final List<Recipe> meals = plan == null
        ? []
        : slot == 'breakfast'
        ? plan.breakfast
        : slot == 'lunch'
        ? plan.lunch
        : plan.dinner;
    final Recipe? plannedRecipe = meals.isNotEmpty ? meals.first : null;
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

  // ── Weekly planner summary ──────────────────────────────────────────────────

  Widget _buildWeeklyPlanner(MealPlan? plan) {
    final int totalMeals = plan == null
        ? 0
        : plan.breakfast.length + plan.lunch.length + plan.dinner.length;

    final List<({Recipe recipe, String slot})> allMeals = plan == null
        ? []
        : [
            for (final r in plan.breakfast) (recipe: r, slot: 'Breakfast'),
            for (final r in plan.lunch) (recipe: r, slot: 'Lunch'),
            for (final r in plan.dinner) (recipe: r, slot: 'Dinner'),
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
                'Weekly Planner',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              TextButton(
                onPressed: () => context.go('/planner'),
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

                WeeklyCalendarStrip.home(
                  baseDate: _calendarBaseDate,
                  activeWeekNumber: _selectedWeekNumber,
                  onWeekChanged: (newWeek) {
                    setState(() => _selectedWeekNumber = newWeek);
                  },
                ),

                // ── Meal cards or empty nudge ──
                if (allMeals.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ...allMeals.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: RecipeCard(
                        type: RecipeCardType.mealPlannerRow,
                        recipe: entry.recipe,
                        slotLabel: entry.slot,
                        onTap: () =>
                            context.push('/recipe-detail/${entry.recipe.id}'),
                      ),
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Center(
                      child: Text(
                        'No meals planned for today.\nHead to the planner to add some!',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.baseBackground.withValues(alpha: 0.7),
                        ),
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

  // ── Recipes feed ────────────────────────────────────────────────────────────

  Widget _buildRecipesSection(BuildContext context, List<Recipe> recipes) {
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
                      child: RecipeCard(
                        type: RecipeCardType.discoveryGrid,
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

  // ── Grocery preview ─────────────────────────────────────────────────────────

  Widget _buildGroceryPreview(List<GroceryItem> items) {
    final int totalItems = items.length;
    final int boughtItems = items.where((i) => i.isBought).length;
    final double percentage = totalItems > 0 ? boughtItems / totalItems : 0.0;
    final preview = items.take(5).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Grocery List',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              TextButton(
                onPressed: () => context.go('/grocery'),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.tertiary,
                ),
                child: const Text('See more'),
              ),
            ],
          ),
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
              child: totalItems == 0
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'Your grocery list is empty.\nPlan some meals to get started!',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppTheme.greyAccent),
                        ),
                      ),
                    )
                  : Column(
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
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppTheme.greyAccent),
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
                                  ref
                                      .read(groceryProvider.notifier)
                                      .toggle(item.id, val ?? false);
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
                            onPressed: () => context.go('/grocery'),
                            style: TextButton.styleFrom(
                              foregroundColor: Theme.of(
                                context,
                              ).colorScheme.tertiary,
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

// ── Profile logout dialog ───────────────────────────────────────────────────

void _showProfileDialog(BuildContext context, WidgetRef ref) {
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
        'Would you like to log out?',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      actionsPadding: const EdgeInsets.only(right: 16, bottom: 16),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: Theme.of(context).textTheme.bodySmall),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(context);
            await ref.read(authRepositoryProvider).signOut();
          },
          child: Text('Logout', style: Theme.of(context).textTheme.bodySmall),
        ),
      ],
    ),
  );
}
