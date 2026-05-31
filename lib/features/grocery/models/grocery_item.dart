import 'package:nyom_recipe_app/features/recipes/models/ingredient_item.dart';

class GroceryItem {
  final String id;
  final IngredientItem ingredient;
  bool isBought;

  GroceryItem({
    required this.id,
    required this.ingredient,
    this.isBought = false,
  });

  factory GroceryItem.fromJson(Map<String, dynamic> json) => GroceryItem(
        id: json['id'] as String,
        ingredient: IngredientItem(
          id: json['id'] as String,
          name: json['name'] as String,
          quantity: json['quantity'] as String? ?? '',
          category: json['category'] != null
              ? IngredientCategory.values.byName(
                  (json['category'] as String).toLowerCase())
              : null,
        ),
        isBought: json['is_bought'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': ingredient.name,
        'quantity': ingredient.quantity,
        'category': ingredient.category?.name,
        'is_bought': isBought,
      };

  GroceryItem copyWith({bool? isBought}) => GroceryItem(
        id: id,
        ingredient: ingredient,
        isBought: isBought ?? this.isBought,
      );
}