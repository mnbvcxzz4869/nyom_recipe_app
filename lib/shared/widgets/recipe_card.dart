import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nyom_recipe_app/features/recipes/models/recipe.dart';
import '../../core/theme/app_theme.dart';

enum RecipeCardType { heroActive, mealPlannerRow, discoveryGrid }

class RecipeCard extends StatelessWidget {
  final RecipeCardType type;
  final Recipe? recipe;
  final VoidCallback? onTap;
  final String? slotLabel;
  const RecipeCard({
    super.key,
    required this.type,
    this.recipe,
    this.onTap,
    this.slotLabel,
  });

  @override
  Widget build(BuildContext context) {
    if (type == RecipeCardType.heroActive && recipe == null) {
      return _buildHeroEmptyState(context);
    }

    switch (type) {
      case RecipeCardType.heroActive:
        return _buildHeroActiveCard(context, recipe!);
      case RecipeCardType.mealPlannerRow:
        return _buildMealPlannerRow(context, recipe!);
      case RecipeCardType.discoveryGrid:
        return _buildDiscoveryGridCard(context, recipe!);
    }
  }

  // ==========================================
  // TYPE 1: TIME-AWARE HERO WORKSPACE VARIANTS
  // ==========================================
  Widget _buildHeroActiveCard(BuildContext context, Recipe recipe) {
    return Material(
      elevation: 2,
      color: AppTheme.cardWhite,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          height: 160,
          child: Row(
            children: [
              Material(
                elevation: 1, // Layered inside the card frame
                borderRadius: BorderRadius.circular(8),
                clipBehavior: Clip.antiAlias,
                child: SizedBox(
                  width: 160,
                  height: 160,
                  child: recipe.imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: recipe.imageUrl!,
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
                          color: AppTheme.baseBackground,
                          child: const Icon(
                            Icons.restaurant_rounded,
                            color: AppTheme.greyAccent,
                            size: 32,
                          ),
                        ),
                ),
              ),
              // Left: Recipe image

              // Right: Text content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      if (slotLabel != null) ...[
                        Text(
                          slotLabel!,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppTheme.greyAccent,
                                fontSize: 12,
                              ),
                        ),
                      ],
                      const SizedBox(height: 4),

                      // Recipe title
                      Text(
                        recipe.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 20,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // Duration + Cook Now button
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            size: 16,
                            color: AppTheme.greyAccent,
                          ),
                          Text(
                            '${recipe.durationMinutes.toString()} Mins',
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(fontSize: 12),
                          ),
                          const Spacer(),
                          // Cook Now button
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.warmYellow,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Cook Now!',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: AppTheme.headingGreen,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.baseBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.greyAccent.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.calendar_today_outlined,
            color: AppTheme.greyAccent,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            'No meal planned for now!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.greyAccent,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // =======================================================
  // TYPE 2: PLANNER SIDE-BY-SIDE COMPACT DESIGN (calendar.png)
  // =======================================================
  Widget _buildMealPlannerRow(BuildContext context, Recipe recipe) {
    return Material(
      color: AppTheme.cardWhite,
      elevation: 2,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            // 1. ELEVATED LEFT THUMBNAIL IMAGE FRAME
            Material(
              elevation: 1,
              borderRadius: BorderRadius.circular(8),
              clipBehavior: Clip.antiAlias,
              child: SizedBox(
                width: 64,
                height: 64,
                child: recipe.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: recipe.imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            Container(color: AppTheme.baseBackground),
                        errorWidget: (context, url, error) => Container(
                          color: AppTheme.baseBackground,
                          child: const Icon(
                            Icons.restaurant_rounded,
                            color: AppTheme.greyAccent,
                            size: 22,
                          ),
                        ),
                      )
                    : Container(
                        color: AppTheme.baseBackground,
                        child: const Center(
                          child: Icon(
                            Icons.image_outlined,
                            color: AppTheme.greyAccent,
                            size: 22,
                          ),
                        ),
                      ),
              ),
            ),

            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 2),

                  Text(
                    recipe.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppTheme.headingGreen,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),

                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 16,
                        color: AppTheme.greyAccent,
                      ),
                      Text(
                        '${recipe.durationMinutes.toString()} Mins',
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(fontSize: 12),
                      ),
                      if (slotLabel != null) ...[
                        Text(
                          ' • ',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppTheme.greyAccent,
                                fontSize: 12,
                              ),
                        ),
                        Text(
                          slotLabel!,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppTheme.greyAccent,
                                fontSize: 12,
                              ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                ],
              ),
            ),

            // Clean trailing decoration indicator
            const Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.greyAccent,
              size: 20,
            ),
            SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  // =======================================================
  // TYPE 3: PORTRAIT DISCOVERY GRID CARD (ELEVATED PICTURE)
  // =======================================================
  Widget _buildDiscoveryGridCard(BuildContext context, Recipe recipe) {
    return Material(
      color: AppTheme.cardWhite,
      elevation: 2,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 6,
              child: Material(
                elevation: 2,
                borderRadius: BorderRadius.circular(8),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    recipe.imageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: recipe.imageUrl!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            placeholder: (context, url) =>
                                Container(color: AppTheme.baseBackground),
                            errorWidget: (context, url, error) => Container(
                              color: AppTheme.baseBackground,
                              child: const Center(
                                child: Icon(
                                  Icons.image_outlined,
                                  color: AppTheme.greyAccent,
                                  size: 28,
                                ),
                              ),
                            ),
                          )
                        : Container(
                            color: AppTheme.baseBackground,
                            width: double.infinity,
                            height: double.infinity,
                            child: const Center(
                              child: Icon(
                                Icons.image_outlined,
                                color: AppTheme.greyAccent,
                                size: 28,
                              ),
                            ),
                          ),

                    // FLOATING CATEGORY BADGE (Ditimpa on top-left)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.warmYellow,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          recipe.category.label,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: AppTheme.headingGreen,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              flex: 2, // Allocates clean space for title and metadata metrics
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 12.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      recipe.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppTheme.headingGreen,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          size: 16,
                          color: AppTheme.greyAccent,
                        ),
                        Text(
                          '${recipe.durationMinutes.toString()} Mins',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
