enum IngredientCategory {produce, protein, dairy, pantry}

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
}

extension IngredientCategoryLabel on IngredientCategory {
  String get label {
    final name = this.name; // e.g. 'produce', 'dairy'
    return name[0].toUpperCase() + name.substring(1); // 'Produce', 'Dairy'
  }
}