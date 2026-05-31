import 'package:nyom_recipe_app/features/recipes/models/ingredient_item.dart';

enum Category { rice, noodle, meat, seafood, vegetables, snacks, desserts }

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

  factory Recipe.fromJson(Map<String, dynamic> json) => Recipe(
        id: json['id'] as String,
        title: json['title'] as String,
        imageUrl: json['image_url'] as String?,
        durationMinutes: json['duration_minutes'] as int,
        category: Category.values.byName(
            (json['category'] as String).toLowerCase()),
        ingredients: (json['ingredients'] as List<dynamic>? ?? [])
            .map((e) => IngredientItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        steps: List<String>.from(json['steps'] ?? []),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'image_url': imageUrl,
        'duration_minutes': durationMinutes,
        'category': category.name,
        'ingredients': ingredients.map((e) => e.toJson()).toList(),
        'steps': steps,
      };
}

extension CategoryLabel on Category {
  String get label {
    final name = this.name;
    return name[0].toUpperCase() + name.substring(1);
  }
}