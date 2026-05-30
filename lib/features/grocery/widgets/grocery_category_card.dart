import 'package:flutter/material.dart';
import 'package:nyom_recipe_app/features/grocery/models/grocery_item.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/grocery_checkbox_tile.dart';

enum IngredientListType {
  groceryCheck, // Dengan Checkbox (Halaman Grocery List)
  recipeView, // Dengan Bullet/Titik bulat biasa (Halaman Detail Resep)
  editableAdd, // Dengan tombol hapus/delete icon (Halaman Tambah Resep)
}

class GroceryCategoryCard extends StatelessWidget {
  final String categoryHeading;
  final List<GroceryItem> items;
  final IngredientListType type;
  final Function(int index, bool newValue)? onItemToggle;
  final Function(int index)? onDeleteItem;

  const GroceryCategoryCard({
    super.key,
    required this.categoryHeading,
    required this.items,
    this.type = IngredientListType.groceryCheck,
    this.onItemToggle,
    this.onDeleteItem,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // --- FIX: JUDUL KATEGORI DI LUAR BOX PUTIH ---
          Padding(
            padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
            child: Text(
              categoryHeading,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),

          // --- BOX MATERIAL: SEKARANG MURNI HANYA MEMBUNGKUS DAFTAR ISI ---
          Material(
            color: AppTheme.cardWhite,
            elevation: 2,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(items.length, (index) {
                  final item = items[index];

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildDynamicIngredientRow(
                        context,
                        index: index,
                        name: item.ingredient.name,
                        qty: item.ingredient.quantity,
                        bought: item.isBought,
                      ),
                      if (index < items.length - 1)
                        Divider(
                          color: AppTheme.crossedOutGreen,
                          thickness: 1,
                          height: 12, // Margin vertikal pembatas yang bersih
                        ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicIngredientRow(
    BuildContext context, {
    required int index,
    required String name,
    required String qty,
    required bool bought,
  }) {
    switch (type) {
      case IngredientListType.groceryCheck:
        return GroceryCheckboxTile(
          title: name,
          measurement: qty,
          isChecked: bought,
          onChanged: (val) {
            if (onItemToggle != null) onItemToggle!(index, val ?? false);
          },
        );

      case IngredientListType.recipeView:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppTheme.headingGreen,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.bodyTextGreen,
                  ),
                ),
              ),
              Text(
                qty,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.greyAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );

      case IngredientListType.editableAdd:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '$name ($qty)',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.bodyTextGreen,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  size: 20,
                  color: Colors.redAccent,
                ),
                onPressed: () {
                  if (onDeleteItem != null) onDeleteItem!(index);
                },
              ),
            ],
          ),
        );
    }
  }
}
