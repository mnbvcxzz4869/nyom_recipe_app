import '../../../core/theme/app_theme.dart';
import '../models/recipe.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nyom_recipe_app/features/grocery/models/grocery_item.dart';
import 'package:nyom_recipe_app/features/recipes/providers/recipe_provider.dart';
import 'package:nyom_recipe_app/shared/widgets/grocery_checkbox_tile.dart';
import 'package:cached_network_image/cached_network_image.dart';

// ---------------------------------------------------------------------------
// Per-ID provider — thin wrapper around the repository
// ---------------------------------------------------------------------------
final recipeByIdProvider = FutureProvider.family<Recipe, String>((
  ref,
  id,
) async {
  return ref.read(recipeRepositoryProvider).fetchById(id);
});

// ---------------------------------------------------------------------------
// Screen entry point — accepts only an ID
// ---------------------------------------------------------------------------
class RecipeDetailScreen extends ConsumerWidget {
  final String recipeId;
  const RecipeDetailScreen({super.key, required this.recipeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncRecipe = ref.watch(recipeByIdProvider(recipeId));

    return asyncRecipe.when(
      loading: () => Scaffold(
        backgroundColor: AppTheme.baseBackground,
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Scaffold(
        backgroundColor: AppTheme.baseBackground,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: AppTheme.greyAccent,
              ),
              const SizedBox(height: 12),
              Text(
                'Failed to load recipe',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref.invalidate(recipeByIdProvider(recipeId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      data: (recipe) => _RecipeDetailBody(recipe: recipe),
    );
  }
}

// ---------------------------------------------------------------------------
// Actual body — same UI as before, but driven by a fetched Recipe
// ---------------------------------------------------------------------------
class _RecipeDetailBody extends StatefulWidget {
  final Recipe recipe;
  const _RecipeDetailBody({required this.recipe});

  @override
  State<_RecipeDetailBody> createState() => _RecipeDetailBodyState();
}

class _RecipeDetailBodyState extends State<_RecipeDetailBody> {
  late List<bool> _checkedIngredients;

  @override
  void initState() {
    super.initState();
    _checkedIngredients = List.filled(widget.recipe.ingredients.length, false);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final topPadding = MediaQuery.of(context).padding.top;

    final List<GroceryItem> groceryItems = widget.recipe.ingredients
        .asMap()
        .entries
        .map(
          (e) => GroceryItem(
            id: e.value.id,
            ingredient: e.value,
            isBought: _checkedIngredients[e.key],
          ),
        )
        .toList();

    return Scaffold(
      backgroundColor: AppTheme.baseBackground,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero image ────────────────────────────────────────────
            Stack(
              children: [
                Material(
                  elevation: 2,
                  borderRadius: BorderRadius.circular(24),
                  clipBehavior: Clip.antiAlias,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(24),
                    ),
                    child: SizedBox(
                      width: screenWidth,
                      height: screenWidth,
                      child: widget.recipe.imageUrl != null
                          ? CachedNetworkImage(
                              imageUrl: widget.recipe.imageUrl!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: AppTheme.baseBackground,
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: AppTheme.headingGreen,
                                child: const Center(
                                  child: Icon(
                                    Icons.restaurant_menu_rounded,
                                    size: 64,
                                    color: AppTheme.warmYellow,
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              color: AppTheme.headingGreen,
                              child: const Center(
                                child: Icon(
                                  Icons.restaurant_menu_rounded,
                                  size: 64,
                                  color: AppTheme.warmYellow,
                                ),
                              ),
                            ),
                    ),
                  ),
                ),
                Positioned(
                  top: topPadding + 4,
                  left: 16,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppTheme.cardWhite.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 16,
                        color: AppTheme.headingGreen,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: topPadding + 4,
                  right: 16,
                  child: GestureDetector(
                    onTap: () =>
                        context.push('/recipe-edit/${widget.recipe.id}', extra: widget.recipe), 
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppTheme.cardWhite.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.edit_outlined,
                        size: 16,
                        color: AppTheme.headingGreen,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // ── Title block ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.warmYellow,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.recipe.category.label,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.headingGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.recipe.title,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 16,
                        color: AppTheme.greyAccent,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.recipe.durationMinutes} Min',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.greyAccent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Ingredients',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),

            // ── Ingredients card ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Material(
                elevation: 2,
                borderRadius: BorderRadius.circular(8),
                color: AppTheme.cardWhite,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: groceryItems.isEmpty
                      ? Text(
                          'No ingredients listed.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppTheme.greyAccent),
                        )
                      : Column(
                          children: List.generate(groceryItems.length, (i) {
                            final item = groceryItems[i];
                            final isLast = i == groceryItems.length - 1;
                            return Column(
                              children: [
                                GroceryCheckboxTile(
                                  title: item.ingredient.name,
                                  measurement: item.ingredient.quantity,
                                  isChecked: _checkedIngredients[i],
                                  onChanged: (val) => setState(
                                    () => _checkedIngredients[i] = val ?? false,
                                  ),
                                ),
                                if (!isLast)
                                  Divider(
                                    color: AppTheme.crossedOutGreen,
                                    thickness: 1,
                                    height: 12,
                                  ),
                              ],
                            );
                          }),
                        ),
                ),
              ),
            ),

            // ── Steps ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
              child: Text(
                'Steps',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
              child: Material(
                elevation: 2,
                borderRadius: BorderRadius.circular(8),
                color: AppTheme.cardWhite,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: widget.recipe.steps.isEmpty
                      ? Text(
                          'No steps listed.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppTheme.greyAccent),
                        )
                      : Column(
                          children: List.generate(widget.recipe.steps.length, (
                            i,
                          ) {
                            final isLast = i == widget.recipe.steps.length - 1;
                            return Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 6,
                                  ),
                                  child: LayoutBuilder(
                                    builder: (context, constraints) {
                                      final text = widget.recipe.steps[i];
                                      final style = Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(height: 1.4, fontSize: 16);
                                      final tp =
                                          TextPainter(
                                            text: TextSpan(
                                              text: text,
                                              style: style,
                                            ),
                                            maxLines: 10,
                                            textDirection: TextDirection.ltr,
                                          )..layout(
                                            maxWidth: constraints.maxWidth - 52,
                                          );
                                      final isMultiLine =
                                          tp.computeLineMetrics().length > 1;

                                      return Row(
                                        crossAxisAlignment: isMultiLine
                                            ? CrossAxisAlignment.start
                                            : CrossAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: 40,
                                            child: Text(
                                              (i + 1).toString().padLeft(
                                                2,
                                                '0',
                                              ),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium
                                                  ?.copyWith(
                                                    color: AppTheme.greyAccent,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 24,
                                                  ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(text, style: style),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                                if (!isLast)
                                  Divider(
                                    color: AppTheme.crossedOutGreen,
                                    thickness: 1,
                                    height: 12,
                                  ),
                              ],
                            );
                          }),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
