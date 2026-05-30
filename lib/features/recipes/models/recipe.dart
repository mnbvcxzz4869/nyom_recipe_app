import 'package:nyom_recipe_app/features/recipes/models/ingredient_item.dart';
enum Category { rice, noodle, meat, seafood, vegetables, snacks, desserts}

class Recipe {
  final String id;
  final String title;
  final String? imageUrl;
  final int durationMinutes;       
  final Category category;            
  final List<IngredientItem> ingredients;
  final List<String> steps;

  const Recipe({
    required this.id,
    required this.title,
    this.imageUrl,
    required this.durationMinutes,
    required this.category,
    this.ingredients = const [],
    this.steps = const [],
  });
}

extension CategoryLabel on Category {
  String get label {
    final name = this.name; // e.g. 'noodle'
    return name[0].toUpperCase() + name.substring(1);
  }
}