import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  // A mock database matching meals to specific date strings ('yyyy-MM-dd')
  // This simulates exactly what happens when the user has already added menu items
  late Map<String, Map<String, RecipeDisplayModel?>> _plannedMealsDatabase;

  @override
  void initState() {
    super.initState();

    // Generate static date string keys for today and tomorrow to display pre-saved meals
    final String todayKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final String tomorrowKey = DateFormat(
      'yyyy-MM-dd',
    ).format(DateTime.now().add(const Duration(days: 1)));

    _plannedMealsDatabase = {
      todayKey: {
        'Breakfast': const RecipeDisplayModel(
          title: 'Fluffy Strawberry Pancakes',
          timeEstimate: '15',
          category: 'Breakfast',
        ),
        'Lunch': null, // Empty slot: will display the Dashed CustomButton
        'Dinner': const RecipeDisplayModel(
          title: 'Grilled Salmon with Avocado',
          timeEstimate: '30',
          category: 'Dinner',
        ),
      },
      tomorrowKey: {
        'Breakfast': null,
        'Lunch': const RecipeDisplayModel(
          title: 'Creamy Garlic Mushroom Pasta',
          timeEstimate: '25',
          category: 'Lunch',
        ),
        'Dinner': null,
      },
    };
  }

  @override
  Widget build(BuildContext context) {
    // Format current selected date to look up dynamic day records from our database map
    final String activeDateKey = DateFormat(
      'yyyy-MM-dd',
    ).format(_activeSelectedDate);
    final Map<String, RecipeDisplayModel?> activeDayMeals =
        _plannedMealsDatabase[activeDateKey] ?? {};

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
                  top: 16.0,
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
                    debugPrint('Date focused: $_activeSelectedDate');
                  },
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildMealSectionSlot(
                    context,
                    'Breakfast',
                    activeDayMeals['Breakfast'],
                  ),
                  SizedBox(height: 8),

                  _buildMealSectionSlot(
                    context,
                    'Lunch',
                    activeDayMeals['Lunch'],
                  ),
                  SizedBox(height: 8),

                  _buildMealSectionSlot(
                    context,
                    'Dinner',
                    activeDayMeals['Dinner'],
                  ),
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
    RecipeDisplayModel? plannedRecipe,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
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
        SizedBox(height: 4),
        plannedRecipe != null
            ? RecipeCard(
                type: RecipeCardType.mealPlannerRow, // Type 2 Card layout
                recipe: plannedRecipe,
                onTap: () {
                  debugPrint(
                    'Navigate to Detailed View for: ${plannedRecipe.title}',
                  );
                },
              )
            : CustomButton(
                text: 'No $sectionLabel planned  — tap to add',
                type: CustomButtonType.dashed,
                onPressed: () => _openRecipePicker(sectionLabel),
              ),
      ],
    );
  }

  void _openRecipePicker(String sectionLabel) {
    debugPrint('Open recipe picking dialog sheet stream for: $sectionLabel');
    // Next, we can plug in the state handler to update _plannedMealsDatabase on selection!
  }
}
