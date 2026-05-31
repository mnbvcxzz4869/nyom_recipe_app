import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:nyom_recipe_app/core/mock/mock_data.dart';
import 'package:nyom_recipe_app/features/planner/models/meal_plan.dart';
import 'package:nyom_recipe_app/features/recipes/models/recipe.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/recipe_card.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/weekly_calendar_strip.dart';

class WeeklyPlannerScreen extends StatefulWidget {
  const WeeklyPlannerScreen({super.key});

  @override
  State<WeeklyPlannerScreen> createState() => _WeeklyPlannerScreenState();
}

class _WeeklyPlannerScreenState extends State<WeeklyPlannerScreen> {
  final DateTime _calendarBaseDate = DateTime.now().subtract(
    const Duration(days: 2),
  );

  int _selectedWeekNumber = 1;
  DateTime _activeSelectedDate = DateTime.now();

  String _dateKey(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  late Map<String, MealPlan> _mealPlans;

  @override
  void initState() {
    super.initState();
    _mealPlans = {
      _dateKey(DateTime.now()): mockMealPlanForDate(DateTime.now()),
      _dateKey(DateTime.now().add(const Duration(days: 1))):
          mockMealPlanForDate(DateTime.now().add(const Duration(days: 1))),
    };
  }

  @override
  Widget build(BuildContext context) {
    final MealPlan activePlan =
        _mealPlans[_dateKey(_activeSelectedDate)] ??
        MealPlan(dateKey: _dateKey(_activeSelectedDate));

    return Scaffold(
      backgroundColor: AppTheme.baseBackground,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          clipBehavior: Clip.none,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  top: 24.0,
                  bottom: 16.0,
                ),
                child: Text(
                  'Weekly Planner',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: WeeklyCalendarStrip(
                  baseDate: _calendarBaseDate,
                  activeWeekNumber: _selectedWeekNumber,
                  showDayRow: true,
                  onWeekChanged: (newWeek) {
                    setState(() {
                      _selectedWeekNumber = newWeek;
                    });
                  },
                  onDateChanged: (newDate) {
                    setState(() {
                      _activeSelectedDate = newDate;
                    });
                  },
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                bottom: 110.0,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildMealSectionSlot(
                    context,
                    'Breakfast',
                    activePlan.breakfast,
                  ),
                  const SizedBox(height: 8),
                  _buildMealSectionSlot(context, 'Lunch', activePlan.lunch),
                  const SizedBox(height: 8),
                  _buildMealSectionSlot(context, 'Dinner', activePlan.dinner),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealSectionSlot(
    BuildContext context,
    String sectionLabel,
    List<Recipe> recipes,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(sectionLabel, style: Theme.of(context).textTheme.titleMedium),
            TextButton(
              onPressed: () => _openRecipePicker(sectionLabel),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.tertiary,
              ),
              child: const Text('+ Add'),
            ),
          ],
        ),
        const SizedBox(height: 4),
        if (recipes.isEmpty)
          CustomButton(
            text: 'No $sectionLabel planned — tap to add',
            type: CustomButtonType.dashed,
            onPressed: () => _openRecipePicker(sectionLabel),
          )
        else
          Column(
            children: recipes
                .map(
                  (recipe) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: RecipeCard(
                      type: RecipeCardType.mealPlannerRow,
                      recipe: recipe,
                      onTap: () {
                        context.push('/recipe-detail/${recipe.id}');
                      },
                    ),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }

  void _openRecipePicker(String sectionLabel) {
    debugPrint('Open recipe picking dialog sheet stream for: $sectionLabel');
  }
}
