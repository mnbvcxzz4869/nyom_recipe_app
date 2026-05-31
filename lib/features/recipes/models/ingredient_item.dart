enum IngredientCategory { produce, protein, dairy, pantry }

class IngredientItem {
  final String id;
  final String name;
  final String quantity;
  final IngredientCategory? category;

  const IngredientItem({
    required this.id,
    required this.name,
    required this.quantity,
    this.category,
  });

  factory IngredientItem.fromJson(Map<String, dynamic> json) => IngredientItem(
        id: json['id'] as String,
        name: json['name'] as String,
        quantity: json['quantity'] as String,
        category: json['category'] != null
            ? IngredientCategory.values.byName(
                (json['category'] as String).toLowerCase())
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'quantity': quantity,
        'category': category?.name,
      };
}

extension IngredientCategoryLabel on IngredientCategory {
  String get label {
    final name = this.name;
    return name[0].toUpperCase() + name.substring(1);
  }
}