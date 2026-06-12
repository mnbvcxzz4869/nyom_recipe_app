import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nyom_recipe_app/features/auth/providers/auth_provider.dart';
import 'package:nyom_recipe_app/features/planner/providers/planner_provider.dart';
import 'package:nyom_recipe_app/features/planner/widgets/meal_slot_section.dart';
import 'package:nyom_recipe_app/features/planner/widgets/recipe_picker_sheet.dart';
import 'package:nyom_recipe_app/features/recipes/models/recipe.dart';
import 'package:nyom_recipe_app/features/recipes/providers/recipe_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/weekly_calendar_strip.dart';
import 'package:nyom_recipe_app/core/providers/calendar_provider.dart';

class WeeklyPlannerScreen extends ConsumerStatefulWidget {
  const WeeklyPlannerScreen({super.key});

  @override
  ConsumerState<WeeklyPlannerScreen> createState() =>
      _WeeklyPlannerScreenState();
}

class _WeeklyPlannerScreenState extends ConsumerState<WeeklyPlannerScreen> {
  int? _selectedWeekNumber;

  final Map<String, Set<String>> _dismissed = {
    'breakfast': {},
    'lunch': {},
    'dinner': {},
  };

  String _dateKey(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  void _onDateChanged(DateTime newDate) {
    ref.read(plannerSelectedDateProvider.notifier).setDate(_dateKey(newDate));
  }

  Future<void> _openRecipePicker(String mealType) async {
    final recipes = ref.read(recipesProvider).asData?.value ?? [];

    if (recipes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No recipes yet — add one first!')),
      );
      return;
    }

    final Recipe? selected = await showModalBottomSheet<Recipe>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RecipePickerSheet(recipes: recipes),
    );

    if (selected != null) {
      try {
        await ref
            .read(plannerMealPlanProvider.notifier)
            .addMeal(mealType.toLowerCase(), selected.id);
      } catch (e) {
        debugPrint('Recipe selection failed: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to add meal. Try again.')),
          );
        }
      }
    }
  }

  Future<void> _removeMeal(String mealType, String recipeId) async {
    final key = mealType.toLowerCase();
    setState(() => _dismissed[key]!.add(recipeId));
    try {
      await ref
          .read(plannerMealPlanProvider.notifier)
          .removeMeal(key, recipeId);
      if (mounted) setState(() => _dismissed[key]!.remove(recipeId));
    } catch (e) {
      debugPrint('Recipe deletion failed: $e');
      if (mounted) {
        setState(() => _dismissed[key]!.remove(recipeId));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to remove meal. Try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final baseDate = ref.watch(calendarBaseDateProvider);
    final currentWeek = ref.watch(currentWeekNumberProvider);
    final signupLoaded = ref.watch(userCreatedAtProvider).hasValue;
    if (signupLoaded && _selectedWeekNumber == null) {
      _selectedWeekNumber = currentWeek;
    }
    final effectiveWeek = _selectedWeekNumber ?? currentWeek;
    final asyncPlan = ref.watch(plannerMealPlanProvider);
    ref.listen(plannerSelectedDateProvider, (_, _) {
      setState(() {
        _dismissed['breakfast']!.clear();
        _dismissed['lunch']!.clear();
        _dismissed['dinner']!.clear();
      });
    });

    return Scaffold(
      backgroundColor: AppTheme.baseBackground,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          clipBehavior: Clip.none,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 16),
                child: Text('Weekly Planner', style: Theme.of(context).textTheme.headlineLarge),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: WeeklyCalendarStrip(
                  baseDate: baseDate,
                  activeWeekNumber: effectiveWeek,
                  showDayRow: true,
                  onWeekChanged: (newWeek) => setState(() => _selectedWeekNumber = newWeek),
                  onDateChanged: _onDateChanged,
                  minWeekNumber: (currentWeek - 2).clamp(1, currentWeek),
                  maxWeekNumber: currentWeek + 2,
                ),
              ),
            ),
            asyncPlan.when(
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, _) => SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: AppTheme.greyAccent),
                      const SizedBox(height: 12),
                      Text('Failed to load meal plan', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => ref.invalidate(plannerMealPlanProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
              data: (plan) => SliverPadding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 110),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    MealSlotSection(
                      label: 'Breakfast',
                      recipes: plan.breakfast,
                      dismissed: _dismissed['breakfast']!,
                      onAdd: () => _openRecipePicker('Breakfast'),
                      onDismiss: (id) => _removeMeal('Breakfast', id),
                    ),
                    const SizedBox(height: 8),
                    MealSlotSection(
                      label: 'Lunch',
                      recipes: plan.lunch,
                      dismissed: _dismissed['lunch']!,
                      onAdd: () => _openRecipePicker('Lunch'),
                      onDismiss: (id) => _removeMeal('Lunch', id),
                    ),
                    const SizedBox(height: 8),
                    MealSlotSection(
                      label: 'Dinner',
                      recipes: plan.dinner,
                      dismissed: _dismissed['dinner']!,
                      onAdd: () => _openRecipePicker('Dinner'),
                      onDismiss: (id) => _removeMeal('Dinner', id),
                    ),
                  ]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}