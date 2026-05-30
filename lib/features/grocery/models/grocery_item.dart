
import 'package:nyom_recipe_app/features/recipes/models/ingredient_item.dart';

class GroceryItem {
  final IngredientItem ingredient;
  bool isBought;

  GroceryItem({
    required this.ingredient,
    this.isBought = false,
  });

  GroceryItem copyWith({bool? isBought}) {
    return GroceryItem(
      ingredient: ingredient,
      isBought: isBought ?? this.isBought,
    );
  }
}