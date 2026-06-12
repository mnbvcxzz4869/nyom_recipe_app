import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class RecipeFilterChips extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  const RecipeFilterChips({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior:
          Clip.none, 
      child: Row(
        children: categories.map((category) {
          final bool isSelected = category == selectedCategory;

          final isLast = category == categories.last;

          return Padding(
            padding: EdgeInsets.only(right: isLast ? 0.0 : 6.0),
            child: _buildTab(context, category, isSelected),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTab(BuildContext context, String category, bool isSelected) {
    return GestureDetector(
      onTap: () => onCategorySelected(category),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.warmYellow : AppTheme.cardWhite,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.transparent : AppTheme.crossedOutGreen,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            category,
            style: isSelected
                ? Theme.of(context).textTheme.titleSmall
                : Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppTheme.crossedOutGreen,
                  ),
          ),
        ),
      ),
    );
  }
}
