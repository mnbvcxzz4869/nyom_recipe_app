import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:nyom_recipe_app/features/auth/providers/auth_provider.dart';
import 'package:nyom_recipe_app/features/planner/models/meal_plan.dart';
import 'package:nyom_recipe_app/features/planner/providers/planner_provider.dart';
import 'package:nyom_recipe_app/features/recipes/models/recipe.dart';
import 'package:nyom_recipe_app/features/recipes/providers/recipe_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/recipe_card.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/weekly_calendar_strip.dart';
import '../../../shared/widgets/recipe_search_bar.dart';

class WeeklyPlannerScreen extends ConsumerStatefulWidget {
  const WeeklyPlannerScreen({super.key});

  @override
  ConsumerState<WeeklyPlannerScreen> createState() =>
      _WeeklyPlannerScreenState();
}

class _WeeklyPlannerScreenState extends ConsumerState<WeeklyPlannerScreen> {
  // baseDate comes from the user's signup date (Week 1 anchor).
  // Falls back to the Monday of the current week while loading.
  DateTime get _calendarBaseDate {
    final signupDate = ref.watch(userCreatedAtProvider).value;
    final anchor = signupDate ?? DateTime.now();
    return anchor.subtract(Duration(days: anchor.weekday - 1));
  }

  /// The week number that contains today, relative to _calendarBaseDate.
  int get _currentWeekNumber {
    final base = _calendarBaseDate;
    final today = DateTime.now();
    final todayMonday = today.subtract(Duration(days: today.weekday - 1));
    return ((todayMonday.difference(base).inDays) ~/ 7) + 1;
  }

  int get _minWeekNumber =>
      (_currentWeekNumber - 2).clamp(1, _currentWeekNumber);
  int get _maxWeekNumber => _currentWeekNumber + 2;

  int _selectedWeekNumber = 1;

  @override
  void initState() {
    super.initState();
    // Start on the current week, not week 1, so the user lands on today.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _selectedWeekNumber = _currentWeekNumber);
    });
  }

  // Tracks optimistically dismissed recipe IDs per meal type
  final Map<String, Set<String>> _dismissed = {
    'breakfast': {},
    'lunch': {},
    'dinner': {},
  };

  String _dateKey(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  void _onDateChanged(DateTime newDate) {
    ref.read(selectedDateProvider.notifier).setDate(_dateKey(newDate));
  }

  // ── Recipe Picker Bottom Sheet ────────────────────────────────────────────
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
      builder: (_) => _RecipePickerSheet(recipes: recipes),
    );

    if (selected != null) {
      try {
        await ref
            .read(mealPlanProvider.notifier)
            .addMeal(mealType.toLowerCase(), selected.id);
      } catch (_) {
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
    // Optimistically hide the card immediately
    setState(() => _dismissed[key]!.add(recipeId));
    try {
      await ref.read(mealPlanProvider.notifier).removeMeal(key, recipeId);
      // Provider will rebuild with the real list — clear dismissed set
      if (mounted) setState(() => _dismissed[key]!.remove(recipeId));
    } catch (_) {
      // Restore card if delete failed
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
    final asyncPlan = ref.watch(mealPlanProvider);

    return Scaffold(
      backgroundColor: AppTheme.baseBackground,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          clipBehavior: Clip.none,
          slivers: [
            // ── Header ───────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 24,
                  bottom: 16,
                ),
                child: Text(
                  'Weekly Planner',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ),
            ),

            // ── Calendar strip ────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: WeeklyCalendarStrip(
                  baseDate: _calendarBaseDate,
                  activeWeekNumber: _selectedWeekNumber,
                  showDayRow: true,
                  onWeekChanged: (newWeek) =>
                      setState(() => _selectedWeekNumber = newWeek),
                  onDateChanged: _onDateChanged,
                  minWeekNumber: _minWeekNumber,
                  maxWeekNumber: _maxWeekNumber,
                ),
              ),
            ),

            // ── Meal slots ────────────────────────────────────────────
            asyncPlan.when(
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
                        'Failed to load meal plan',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => ref.invalidate(mealPlanProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),

              data: (plan) => SliverPadding(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  bottom: 110,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildMealSlot('Breakfast', plan.breakfast, plan),
                    const SizedBox(height: 8),
                    _buildMealSlot('Lunch', plan.lunch, plan),
                    const SizedBox(height: 8),
                    _buildMealSlot('Dinner', plan.dinner, plan),
                  ]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealSlot(String label, List<Recipe> recipes, MealPlan plan) {
    final key = label.toLowerCase();
    final visible = recipes
        .where((r) => !(_dismissed[key]?.contains(r.id) ?? false))
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.titleMedium),
            TextButton(
              onPressed: () => _openRecipePicker(label),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.tertiary,
              ),
              child: const Text('+ Add'),
            ),
          ],
        ),
        const SizedBox(height: 4),
        if (visible.isEmpty)
          CustomButton(
            text: 'No $label planned — tap to add',
            type: CustomButtonType.dashed,
            onPressed: () => _openRecipePicker(label),
          )
        else
          Column(
            children: visible.map((recipe) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Dismissible(
                  key: ValueKey('${label}_${recipe.id}'),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) => _removeMeal(label, recipe.id),
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: AppTheme.greyAccent.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.delete_outline,
                      color: AppTheme.greyAccent,
                    ),
                  ),
                  child: RecipeCard(
                    type: RecipeCardType.mealPlannerRow,
                    recipe: recipe,
                    onTap: () => context.push('/recipe-detail/${recipe.id}'),
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}

// ── Recipe Picker Bottom Sheet ────────────────────────────────────────────────
class _RecipePickerSheet extends StatefulWidget {
  final List<Recipe> recipes;
  const _RecipePickerSheet({required this.recipes});

  @override
  State<_RecipePickerSheet> createState() => _RecipePickerSheetState();
}

class _RecipePickerSheetState extends State<_RecipePickerSheet> {
  final TextEditingController _search = TextEditingController();

  List<Recipe> get _filtered {
    if (_search.text.isEmpty) return widget.recipes;
    return widget.recipes
        .where(
          (r) => r.title.toLowerCase().contains(_search.text.toLowerCase()),
        )
        .toList();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.baseBackground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Handle ──
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 16),
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.greyAccent.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),

              // ── Title + Search ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pick a Recipe',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 12),
                    RecipeSearchBar(
                      controller: _search,
                      hintText: 'Search recipes...',
                      onChanged: (_) => setState(() {}),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ── Recipe list ──
              Expanded(
                child: _filtered.isEmpty
                    ? Center(
                        child: Text(
                          'No recipes match',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppTheme.greyAccent),
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                        itemCount: _filtered.length,
                        itemBuilder: (context, index) {
                          final recipe = _filtered[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: RecipeCard(
                              type: RecipeCardType.mealPlannerRow,
                              recipe: recipe,
                              onTap: () => Navigator.pop(context, recipe),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
