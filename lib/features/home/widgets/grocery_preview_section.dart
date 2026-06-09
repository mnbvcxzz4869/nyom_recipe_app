import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nyom_recipe_app/features/grocery/models/grocery_item.dart';
import 'package:nyom_recipe_app/features/grocery/providers/grocery_provider.dart';
import 'package:nyom_recipe_app/shared/widgets/grocery_checkbox_tile.dart';
import '../../../core/theme/app_theme.dart';

class GroceryPreviewSection extends ConsumerWidget {
  final List<GroceryItem> items;

  const GroceryPreviewSection({super.key, required this.items});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              Text('Grocery List', style: Theme.of(context).textTheme.titleMedium),
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
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: totalItems == 0
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'Your grocery list is empty.\nPlan some meals to get started!',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.greyAccent,
                              ),
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
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.greyAccent,
                                  ),
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
                              foregroundColor: Theme.of(context).colorScheme.tertiary,
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