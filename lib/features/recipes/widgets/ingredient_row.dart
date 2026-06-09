import 'package:flutter/material.dart';
import 'package:nyom_recipe_app/core/theme/app_theme.dart';

class IngredientEntry {
  final TextEditingController nameController;
  final TextEditingController qtyController;

  IngredientEntry({String name = '', String qty = ''})
      : nameController = TextEditingController(text: name),
        qtyController = TextEditingController(text: qty);

  void dispose() {
    nameController.dispose();
    qtyController.dispose();
  }
}

class IngredientRow extends StatelessWidget {
  final IngredientEntry entry;
  final bool canDelete;
  final VoidCallback onDelete;
  final bool showDivider;

  const IngredientRow({
    super.key,
    required this.entry,
    required this.canDelete,
    required this.onDelete,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ObjectKey(entry),
      direction: canDelete ? DismissDirection.endToStart : DismissDirection.none,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppTheme.greyAccent.withValues(alpha: 0.25),
        child: Icon(Icons.delete_outline, color: AppTheme.greyAccent),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: entry.nameController,
                    style: Theme.of(context).textTheme.bodyMedium,
                    decoration: InputDecoration(
                      hintText: 'Ingredient name',
                      hintStyle: Theme.of(context).textTheme.labelLarge,
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      isDense: true,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: entry.qtyController,
                    textAlign: TextAlign.end,
                    style: Theme.of(context).textTheme.bodyMedium,
                    decoration: InputDecoration(
                      hintText: 'Qty',
                      hintStyle: Theme.of(context).textTheme.labelLarge,
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (showDivider)
            Divider(
              height: 1,
              thickness: 1,
              color: AppTheme.crossedOutGreen,
              indent: 16,
              endIndent: 16,
            ),
        ],
      ),
    );
  }
}