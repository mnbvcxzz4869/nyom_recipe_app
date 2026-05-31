import 'package:flutter/material.dart';
import 'package:nyom_recipe_app/core/mock/mock_data.dart';
import 'package:nyom_recipe_app/features/grocery/models/grocery_item.dart';
import 'package:nyom_recipe_app/features/recipes/models/ingredient_item.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/weekly_calendar_strip.dart';
import '../widgets/grocery_progress_card.dart';
import '../widgets/grocery_category_card.dart';

class GroceryListScreen extends StatefulWidget {
  const GroceryListScreen({super.key});

  @override
  State<GroceryListScreen> createState() => _GroceryListScreenState();
}

class _GroceryListScreenState extends State<GroceryListScreen> {
  final DateTime _calendarBaseDate = DateTime.now().subtract(
    const Duration(days: 2),
  );
  int _selectedWeekNumber = 1;

  List<GroceryItem> _groceryItems = mockGroceryItems.toList();

  Map<String, List<GroceryItem>> get _grouped {
    final map = <String, List<GroceryItem>>{};
    for (final item in _groceryItems) {
      (map[item.ingredient.category?.label ?? 'Other'] ??= []).add(item);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    int totalItems = 0;
    int boughtItems = 0;

    for (final itemsList in _grouped.values) {
      totalItems += itemsList.length;
      boughtItems += itemsList.where((item) => item.isBought).length;
    }

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
                  bottom: 8.0,
                ),
                child: Text(
                  'Grocery List',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: WeeklyCalendarStrip.grocery(
                  baseDate: _calendarBaseDate,
                  activeWeekNumber: _selectedWeekNumber,
                  onWeekChanged: (newWeek) {
                    setState(() {
                      _selectedWeekNumber = newWeek;
                    });
                  },
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 10.0,
                ),
                child: GroceryProgressCard(
                  totalItems: totalItems,
                  boughtItems: boughtItems,
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 8.0)),

            SliverPadding(
              padding: const EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                bottom: 110.0,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  _grouped.keys.map((category) {
                    return GroceryCategoryCard(
                      categoryHeading: category,
                      items: _grouped[category]!,
                      type: IngredientListType.groceryCheck,
                      onItemToggle: (itemIndex, newValue) {
                        setState(() {
                          _grouped[category]![itemIndex].isBought = newValue;
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
