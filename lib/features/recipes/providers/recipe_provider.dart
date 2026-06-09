import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nyom_recipe_app/features/recipes/repositories/recipe_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/recipe.dart';

final recipeRepositoryProvider = Provider(
  (ref) => RecipeRepository(Supabase.instance.client),
);

final recipesProvider = AsyncNotifierProvider<RecipeNotifier, List<Recipe>>(
  RecipeNotifier.new,
);

final recipeByIdProvider = FutureProvider.family<Recipe, String>((
  ref,
  id,
) async {
  return ref.read(recipeRepositoryProvider).fetchById(id);
});

class RecipeNotifier extends AsyncNotifier<List<Recipe>> {
  @override
  Future<List<Recipe>> build() async {
    // Subscribe to Supabase Realtime on the recipes table.
    // Any INSERT / UPDATE / DELETE from any device triggers a local refresh.
    final channel = Supabase.instance.client
        .channel('recipes_changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'recipes',
          callback: (payload) {
            // Invalidate the per-recipe cache if we know the affected ID.
            final affectedId =
                (payload.oldRecord['id'] ?? payload.newRecord['id'])
                    ?.toString();
            if (affectedId != null) {
              ref.invalidate(recipeByIdProvider(affectedId));
            }
            ref.invalidateSelf();
          },
        )
        .subscribe();

    // Unsubscribe when the provider is disposed (e.g. user logs out).
    ref.onDispose(() {
      Supabase.instance.client.removeChannel(channel);
    });

    return ref.read(recipeRepositoryProvider).fetchAll();
  }

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
    ref.invalidate(recipeByIdProvider(id));
    ref.invalidateSelf();
  }

  Future<String?> uploadImage(File file) async {
    try {
      return await ref.read(recipeRepositoryProvider).uploadImage(file);
    } catch (e) {
      debugPrint('Image upload failed: $e');
      return null;
    }
  }
}
