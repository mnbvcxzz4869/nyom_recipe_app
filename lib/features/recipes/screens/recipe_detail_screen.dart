import 'package:flutter/material.dart';
import 'package:nyom_recipe_app/features/grocery/models/grocery_item.dart';
import 'package:nyom_recipe_app/shared/widgets/grocery_checkbox_tile.dart';
import '../../../core/theme/app_theme.dart';
import '../models/recipe.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
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
            // ── Hero image as Stack so button overlays it ──────────────
            Stack(
              children: [
                // Square image with rounded bottom corners
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
                      height: screenWidth, // square
                      child: widget.recipe.imageUrl != null
                          ? Image.network(
                              widget.recipe.imageUrl!,
                              fit: BoxFit.cover,
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

                // Back button — square rounded container, top-left
                Positioned(
                  top: topPadding + 24,
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
              ],
            ),

            // ── Title block ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category chip
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

                  // Title
                  Text(
                    widget.recipe.title,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 8),

                  // Duration row
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

                  // Ingredients heading
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
                  child: Column(
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

            // ── Steps heading ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
              child: Text(
                'Steps',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),

            // ── Steps card ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
              child: Material(
                elevation: 2,
                borderRadius: BorderRadius.circular(8),
                color: AppTheme.cardWhite,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: List.generate(widget.recipe.steps.length, (i) {
                      final isLast = i == widget.recipe.steps.length - 1;
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final text = widget.recipe.steps[i];
                                final style = Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(height: 1.4, fontSize: 16);
                                final tp = TextPainter(
                                  text: TextSpan(text: text, style: style),
                                  maxLines: 10,
                                  textDirection: TextDirection.ltr,
                                )..layout(maxWidth: constraints.maxWidth - 52);
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
                                        (i + 1).toString().padLeft(2, '0'),
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
                                    Expanded(child: Text(text, style: style)),
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
