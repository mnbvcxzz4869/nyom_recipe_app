import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class GroceryProgressCard extends StatelessWidget {
  final int totalItems;
  final int boughtItems;

  const GroceryProgressCard({
    super.key,
    required this.totalItems,
    required this.boughtItems,
  });

  @override
  Widget build(BuildContext context) {
    final double percentage = totalItems > 0 ? boughtItems / totalItems : 0.0;

    return Material(
      color: AppTheme.cardWhite,
      elevation: 2,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$boughtItems/$totalItems of $totalItems Items done',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '${((boughtItems / totalItems) * 100).round()}%',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: percentage,
                minHeight: 8,
                backgroundColor: AppTheme.baseBackground,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppTheme.greyAccent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
