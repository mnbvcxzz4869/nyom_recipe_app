import 'package:flutter/material.dart';
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

  // Mock checklist state cache split by group categories
  final Map<String, List<Map<String, dynamic>>> _mockIngredientsDatabase = {
    'Vegetables': [
      {'name': 'Fresh Strawberries', 'qty': '250g', 'bought': false},
      {'name': 'Avocado', 'qty': '2 pcs', 'bought': true},
      {'name': 'Garlic Mushrooms', 'qty': '100g', 'bought': false},
    ],
    'Meat & Seafood': [
      {'name': 'Salmon Fillets', 'qty': '2 portions', 'bought': false},
    ],
  };

  @override
  Widget build(BuildContext context) {
    // Dynamically calculate totals across categories for the Progress view element
    int totalItems = 0;
    int boughtItems = 0;

    for (var itemsList in _mockIngredientsDatabase.values) {
      totalItems += itemsList.length;
      boughtItems += itemsList.where((item) => item['bought'] == true).length;
    }

    return Scaffold(
      backgroundColor: AppTheme.baseBackground,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          clipBehavior: Clip.none,
          slivers: [
            // Title Header Row
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  top: 16.0,
                  bottom: 8.0,
                ),
                child: Text(
                  'Grocery List',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ),
            ),

            // --- REUSABLE CALENDAR STRIP (Grocery Mode Variant) ---
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

            // --- 1. DYNAMIC PROGRESS CARD INJECTION BLOCK (`image_d8a9c6.png`) ---
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

            // --- 2. CONTAINER-ENCAPSULATED CATEGORY LIST CARDS PANEL ---
            SliverPadding(
              padding: const EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                bottom: 110.0,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  _mockIngredientsDatabase.keys.map((category) {
                    return GroceryCategoryCard(
                      categoryHeading: category,
                      items: _mockIngredientsDatabase[category]!,
                      type: IngredientListType
                          .groceryCheck, // Set eksplisit menggunakan checkbox belanjaan
                      onItemToggle: (itemIndex, newValue) {
                        setState(() {
                          _mockIngredientsDatabase[category]![itemIndex]['bought'] =
                              newValue;
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
