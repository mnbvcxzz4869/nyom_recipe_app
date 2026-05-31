import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/grocery_item.dart';
import '../repositories/grocery_repository.dart';

final groceryRepositoryProvider = Provider((ref) =>
    GroceryRepository(Supabase.instance.client));

final groceryProvider =
    AsyncNotifierProvider<GroceryNotifier, List<GroceryItem>>(
        GroceryNotifier.new);

class GroceryNotifier extends AsyncNotifier<List<GroceryItem>> {
  @override
  Future<List<GroceryItem>> build() =>
      ref.read(groceryRepositoryProvider).fetchAll();

  Future<void> toggle(String id, bool isBought) async {
    await ref.read(groceryRepositoryProvider).toggleBought(id, isBought);
    ref.invalidateSelf();
  }

  Future<void> add({
    required String name,
    required String quantity,
    String? category,
  }) async {
    await ref.read(groceryRepositoryProvider).add(
          name: name,
          quantity: quantity,
          category: category,
        );
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
}