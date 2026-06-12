import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nyom_recipe_app/features/recipes/models/recipe.dart';
import '../../../core/theme/app_theme.dart';

class MealPlannerRecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback? onTap;
  final String? slotLabel;

  const MealPlannerRecipeCard({
    super.key,
    required this.recipe,
    this.onTap,
    this.slotLabel,
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
        child: Row(
          children: [
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
                      SizedBox(width: 2),
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
}
