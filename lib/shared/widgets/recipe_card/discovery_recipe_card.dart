import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nyom_recipe_app/features/recipes/models/recipe.dart';
import '../../../core/theme/app_theme.dart';

/// Portrait grid card used in the discovery feed.
class DiscoveryRecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback? onTap;

  const DiscoveryRecipeCard({
    super.key,
    required this.recipe,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
                        SizedBox(width: 2,),
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