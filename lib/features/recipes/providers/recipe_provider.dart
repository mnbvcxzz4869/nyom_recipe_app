import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nyom_recipe_app/features/recipes/repositories/recipe_repository,.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/recipe.dart';

final recipeRepositoryProvider = Provider(
  (ref) => RecipeRepository(Supabase.instance.client),
);

final recipesProvider = AsyncNotifierProvider<RecipeNotifier, List<Recipe>>(
  RecipeNotifier.new,
);

class RecipeNotifier extends AsyncNotifier<List<Recipe>> {
  @override
  Future<List<Recipe>> build() => ref.read(recipeRepositoryProvider).fetchAll();

  Future<void> add(Recipe recipe) async {
    await ref.read(recipeRepositoryProvider).create(recipe);
    ref.invalidateSelf();
  }

  Future<void> edit(Recipe recipe) async {
    await ref.read(recipeRepositoryProvider).update(recipe);
    ref.invalidateSelf();
  }

  Future<void> delete(String id) async {
    await ref.read(recipeRepositoryProvider).delete(id);
    ref.invalidateSelf();
  }
}
