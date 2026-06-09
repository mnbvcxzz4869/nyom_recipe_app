import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nyom_recipe_app/core/providers/calendar_provider.dart';
import 'package:nyom_recipe_app/features/planner/models/meal_plan.dart';
import 'package:nyom_recipe_app/features/planner/providers/planner_provider.dart';
import 'package:nyom_recipe_app/features/recipes/models/recipe.dart';
import 'package:nyom_recipe_app/shared/widgets/recipe_card/meal_planner_recipe_card.dart';
import 'package:nyom_recipe_app/shared/widgets/weekly_calendar_strip.dart';
import 'package:nyom_recipe_app/features/auth/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';

class WeeklyPlannerPreview extends ConsumerStatefulWidget {
  final MealPlan? plan;
  final DateTime baseDate;

  const WeeklyPlannerPreview({
    super.key,
    required this.plan,
    required this.baseDate,
  });

  @override
  ConsumerState<WeeklyPlannerPreview> createState() =>
      _WeeklyPlannerPreviewState();
}

class _WeeklyPlannerPreviewState extends ConsumerState<WeeklyPlannerPreview> {
  // Nullable until currentWeekNumberProvider resolves from its async dependency.
  // Once set, user interaction can override it freely.
  int? _selectedWeekNumber;

  // Tracks whether the user has manually changed the week. If they haven't,
  // we keep syncing to currentWeekNumberProvider as it resolves.
  bool _userHasInteracted = false;

  String _toDateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final plan = widget.plan;
    final baseDate = widget.baseDate;

    final currentWeek = ref.watch(currentWeekNumberProvider);
    final signupLoaded = ref.watch(userCreatedAtProvider).hasValue;

    if (!_userHasInteracted && signupLoaded) {
      _selectedWeekNumber = currentWeek;
    }

    // Don't render until we have real data — avoids the week-1 flash
    if (!signupLoaded && _selectedWeekNumber == null) {
      return const SizedBox.shrink();
    }

    final effectiveWeek = _selectedWeekNumber ?? currentWeek;

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
                        'Week $effectiveWeek',
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
                  baseDate: baseDate,
                  activeWeekNumber: effectiveWeek,
                  onWeekChanged: (newWeek) {
                    setState(() {
                      _selectedWeekNumber = newWeek;
                      _userHasInteracted = true;
                    });
                    final selectedMonday = baseDate.add(
                      Duration(days: (newWeek - 1) * 7),
                    );
                    ref
                        .read(selectedDateProvider.notifier)
                        .setDate(_toDateKey(selectedMonday));
                  },
                  onDateChanged: (selectedDate) {
                    setState(() => _userHasInteracted = true);
                    ref
                        .read(selectedDateProvider.notifier)
                        .setDate(_toDateKey(selectedDate));
                  },
                ),
                if (allMeals.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ...allMeals.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: MealPlannerRecipeCard(
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
}
