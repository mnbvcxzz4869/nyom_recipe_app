import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nyom_recipe_app/features/grocery/models/grocery_item.dart';
import 'package:nyom_recipe_app/features/grocery/providers/grocery_provider.dart';
import 'package:nyom_recipe_app/features/recipes/models/ingredient_item.dart';
import 'package:nyom_recipe_app/shared/utils/week_key.dart';
import 'package:nyom_recipe_app/shared/widgets/app_loading_overlay.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/weekly_calendar_strip.dart';
import '../widgets/grocery_progress_card.dart';
import '../widgets/grocery_category_card.dart';
import 'package:nyom_recipe_app/core/providers/calendar_provider.dart';

class GroceryListScreen extends ConsumerStatefulWidget {
  const GroceryListScreen({super.key});

  @override
  ConsumerState<GroceryListScreen> createState() => _GroceryListScreenState();
}

class _GroceryListScreenState extends ConsumerState<GroceryListScreen> {
  int? _selectedWeekNumber;

  String _selectedWeekKey(DateTime baseDate) {
    final selectedMonday = baseDate.add(
      Duration(days: ((_selectedWeekNumber ?? 1) - 1) * 7),
    );
    final dateKey =
        '${selectedMonday.year}-${selectedMonday.month.toString().padLeft(2, '0')}-${selectedMonday.day.toString().padLeft(2, '0')}';
    return isoWeekKey(dateKey);
  }

  Map<String, List<GroceryItem>> _grouped(List<GroceryItem> items) {
    final map = <String, List<GroceryItem>>{};
    for (final item in items) {
      (map[item.ingredient.category?.label ?? 'Other'] ??= []).add(item);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final baseDate = ref.watch(calendarBaseDateProvider); 
    final currentWeek = ref.watch(currentWeekNumberProvider); 
    final asyncItems = ref.watch(groceryProvider);

    if (baseDate == null || currentWeek == null) {
      return const Scaffold(body: AppLoadingOverlay());
    }

    if (_selectedWeekNumber == null) {
      _selectedWeekNumber = currentWeek;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(selectedGroceryWeekProvider.notifier).state = _selectedWeekKey(
          baseDate,
        );
      });
    }

    return asyncItems.when(
      loading: () => const Scaffold(body: AppLoadingOverlay()),
      error: (err, _) => Scaffold(
        backgroundColor: AppTheme.baseBackground,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: AppTheme.greyAccent,
              ),
              const SizedBox(height: 12),
              Text(
                'Could not load grocery list',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref.invalidate(groceryProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      data: (items) => _buildScreen(context, items, baseDate, currentWeek),
    );
  }

  Widget _buildScreen(
    BuildContext context,
    List<GroceryItem> items,
    DateTime baseDate,
    int currentWeek,
  ) {
    final grouped = _grouped(items);

    int totalItems = 0;
    int boughtItems = 0;
    for (final list in grouped.values) {
      totalItems += list.length;
      boughtItems += list.where((i) => i.isBought).length;
    }

    return Scaffold(
      backgroundColor: AppTheme.baseBackground,
      floatingActionButton: boughtItems > 0
          ? FloatingActionButton.extended(
              onPressed: () async {
                await ref.read(groceryProvider.notifier).clearBought();
              },
              backgroundColor: AppTheme.headingGreen,
              icon: const Icon(Icons.delete_sweep_rounded, color: Colors.white),
              label: const Text(
                'Clear bought',
                style: TextStyle(color: Colors.white),
              ),
            )
          : null,
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
                  top: 4.0,
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
                  baseDate: baseDate,
                  activeWeekNumber: _selectedWeekNumber!,
                  onWeekChanged: (newWeek) {
                    setState(() => _selectedWeekNumber = newWeek);
                    ref.read(selectedGroceryWeekProvider.notifier).state =
                        _selectedWeekKey(baseDate);
                  },
                  minWeekNumber: (currentWeek - 2).clamp(1, currentWeek),
                  maxWeekNumber: currentWeek + 2,
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

            if (items.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.remove_shopping_cart_outlined,
                        size: 48,
                        color: AppTheme.greyAccent,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No grocery items yet',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Plan meals in the Weekly Planner\nto auto-populate your list.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.greyAccent,
                        ),
                      ),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  bottom: 110.0,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    grouped.keys.map((category) {
                      final categoryItems = grouped[category]!;
                      return GroceryCategoryCard(
                        categoryHeading: category,
                        items: categoryItems,
                        type: IngredientListType.groceryCheck,
                        onItemToggle: (itemIndex, newValue) {
                          ref
                              .read(groceryProvider.notifier)
                              .toggle(categoryItems[itemIndex].id, newValue);
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
