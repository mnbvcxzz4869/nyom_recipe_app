import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nyom_recipe_app/features/recipes/models/recipe.dart';
import '../../../core/theme/app_theme.dart';

class HeroRecipeCard extends StatelessWidget {
  final Recipe? recipe;
  final VoidCallback? onTap;
  final String? slotLabel;

  const HeroRecipeCard({
    super.key,
    this.recipe,
    this.onTap,
    this.slotLabel,
  });

  @override
  Widget build(BuildContext context) {
    if (recipe == null) return _buildEmptyState(context);
    return _buildActiveCard(context, recipe!);
  }

  Widget _buildActiveCard(BuildContext context, Recipe recipe) {
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
                          SizedBox(width: 2,),
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
                              horizontal: 6,
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

  Widget _buildEmptyState(BuildContext context) {
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
}