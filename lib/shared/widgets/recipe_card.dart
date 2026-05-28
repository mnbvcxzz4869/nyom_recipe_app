import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

enum RecipeCardType { heroActive, mealPlannerRow, discoveryGrid }

class RecipeDisplayModel {
  final String title;
  final String timeEstimate;
  final String category;
  final String? imageUrl;

  const RecipeDisplayModel({
    required this.title,
    required this.timeEstimate,
    required this.category,
    this.imageUrl,
  });
}

class RecipeCard extends StatelessWidget {
  final RecipeCardType type;
  final RecipeDisplayModel? recipe;
  final VoidCallback? onTap;

  const RecipeCard({super.key, required this.type, this.recipe, this.onTap});

  @override
  Widget build(BuildContext context) {
    if (type == RecipeCardType.heroActive && recipe == null) {
      return _buildHeroEmptyState(context);
    }

    final data =
        recipe ??
        const RecipeDisplayModel(
          title: 'Delicious Sample Meal',
          timeEstimate: '25',
          category: 'Healthy',
        );

    switch (type) {
      case RecipeCardType.heroActive:
        return _buildHeroActiveCard(context, data);
      case RecipeCardType.mealPlannerRow:
        return _buildMealPlannerRow(context, data);
      case RecipeCardType.discoveryGrid:
        return _buildDiscoveryGridCard(context, data);
    }
  }

  // ==========================================
  // TYPE 1: TIME-AWARE HERO WORKSPACE VARIANTS
  // ==========================================
  Widget _buildHeroActiveCard(BuildContext context, RecipeDisplayModel data) {
    return Material(
      elevation: 2,
      color: AppTheme.cardWhite,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TODAY\'S BREAKFAST',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.greyAccent,
                        letterSpacing: 1.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      data.title,
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge?.copyWith(fontSize: 20),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          size: 14,
                          color: AppTheme.greyAccent,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${data.timeEstimate} min',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(width: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.warmYellow.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            data.category,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AppTheme.headingGreen,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: AppTheme.baseBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.restaurant_rounded,
                  color: AppTheme.greyAccent,
                  size: 32,
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
  Widget _buildMealPlannerRow(BuildContext context, RecipeDisplayModel data) {
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
              elevation: 1, // Layered inside the card frame
              borderRadius: BorderRadius.circular(8),
              clipBehavior: Clip.antiAlias,
              child: Container(
                width: 64,
                height: 64,
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

            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 2),

                  Text(
                    data.title,
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
                      const SizedBox(width: 4),
                      Text(
                        '${data.timeEstimate} Mins',
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(fontSize: 12),
                      ),
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
  Widget _buildDiscoveryGridCard(
    BuildContext context,
    RecipeDisplayModel data,
  ) {
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
                    Container(
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
                          data.category,
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
                      data.title,
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
                        const SizedBox(width: 4),
                        Text(
                          '${data.timeEstimate} Mins',
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
