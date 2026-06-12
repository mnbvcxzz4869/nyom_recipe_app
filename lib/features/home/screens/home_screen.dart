import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nyom_recipe_app/core/providers/calendar_provider.dart';
import 'package:nyom_recipe_app/features/grocery/providers/grocery_provider.dart';
import 'package:nyom_recipe_app/features/planner/providers/planner_provider.dart';
import 'package:nyom_recipe_app/features/recipes/providers/recipe_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/grocery_preview_section.dart';
import '../widgets/home_header.dart';
import '../widgets/recipes_feed_section.dart';
import '../widgets/today_plan_card.dart';
import '../widgets/weekly_planner_preview.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final today = DateTime.now();
      final todayKey =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      ref.read(selectedDateProvider.notifier).setDate(todayKey);
    });
  }

  @override
  Widget build(BuildContext context) {
    // todayMealPlanProvider is always pinned to today — never affected by
    // the calendar date selection. Use .value so switching dates doesn't
    // flash a loading spinner; previous data stays visible while refreshing.
    final todayPlan = ref.watch(todayMealPlanProvider).value;
    final baseDate = ref.watch(calendarBaseDateProvider);
    final selectedPlan = ref.watch(mealPlanProvider).value;
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
              const HomeHeader(),
              const SizedBox(height: 16),

              // ── Today's hero card ──────────────────────────────────────
              TodayPlanCard(plan: todayPlan),
              const SizedBox(height: 20),

              // ── Weekly planner summary ─────────────────────────────────
              WeeklyPlannerPreview(plan: selectedPlan, baseDate: baseDate),
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
                error: (_, _) => const SizedBox.shrink(),
                data: (recipes) => RecipesFeedSection(recipes: recipes),
              ),
              const SizedBox(height: 20),

              // ── Grocery preview ────────────────────────────────────────
              groceryAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
                data: (items) => GroceryPreviewSection(items: items),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
