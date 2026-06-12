import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:nyom_recipe_app/features/recipes/models/recipe.dart';
import 'package:nyom_recipe_app/shared/utils/week_key.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/grocery_item.dart';
import '../repositories/grocery_repository.dart';
import '../../auth/providers/auth_provider.dart';

final groceryRepositoryProvider = Provider(
  (ref) => GroceryRepository(Supabase.instance.client),
);

final selectedGroceryWeekProvider = StateProvider<String>((ref) {
  return isoWeekKey(todayKey());
});

final groceryProvider =
    AsyncNotifierProvider<GroceryNotifier, List<GroceryItem>>(
      GroceryNotifier.new,
    );

class GroceryNotifier extends AsyncNotifier<List<GroceryItem>> {
  @override
  Future<List<GroceryItem>> build() async {
    final userId = ref.watch(currentUserIdProvider);
    if (userId == null) return [];

    final weekKey = ref.watch(selectedGroceryWeekProvider);
    final items = await ref
        .read(groceryRepositoryProvider)
        .fetchAll(weekKey: weekKey);
    items.sort(
      (a, b) => a.ingredient.name.toLowerCase().compareTo(
        b.ingredient.name.toLowerCase(),
      ),
    );
    return items;
  }

  Future<void> toggle(String id, bool isBought) async {
    await ref.read(groceryRepositoryProvider).toggleBought(id, isBought);
    ref.invalidateSelf();
  }

  Future<void> add({
    required String name,
    required String quantity,
    String? category,
  }) async {
    await ref
        .read(groceryRepositoryProvider)
        .add(name: name, quantity: quantity, category: category);
    ref.invalidateSelf();
  }

  Future<void> delete(String id) async {
    await ref.read(groceryRepositoryProvider).delete(id);
    ref.invalidateSelf();
  }

  Future<void> clearBought() async {
    await ref.read(groceryRepositoryProvider).clearBought();
    ref.invalidateSelf();
  }

  Future<void> addFromRecipe({
    required Recipe recipe,
    required String weekKey,
  }) async {
    await ref
        .read(groceryRepositoryProvider)
        .addFromRecipe(recipe: recipe, weekKey: weekKey);
    ref.invalidateSelf();
  }

  Future<void> removeByRecipe({
    required String recipeId,
    required String weekKey,
  }) async {
    await ref
        .read(groceryRepositoryProvider)
        .removeByRecipe(recipeId: recipeId, weekKey: weekKey);
    ref.invalidateSelf();
  }
}
