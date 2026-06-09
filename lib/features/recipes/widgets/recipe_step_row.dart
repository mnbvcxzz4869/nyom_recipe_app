import 'package:flutter/material.dart';
import 'package:nyom_recipe_app/core/theme/app_theme.dart';

class RecipeStepRow extends StatelessWidget {
  final int index;
  final TextEditingController controller;
  final bool canDelete;
  final VoidCallback onDelete;
  final bool showDivider;

  const RecipeStepRow({
    super.key,
    required this.index,
    required this.controller,
    required this.canDelete,
    required this.onDelete,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ObjectKey(controller),
      direction: canDelete ? DismissDirection.endToStart : DismissDirection.none,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppTheme.greyAccent.withValues(alpha: 0.25),
        child: Icon(Icons.delete_outline, color: AppTheme.greyAccent),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 40,
                  height: 30,
                  child: Center(
                    child: Text(
                      (index + 1).toString().padLeft(2, '0'),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.greyAccent,
                            fontWeight: FontWeight.w600,
                            fontSize: 24,
                          ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: controller,
                    maxLines: null,
                    minLines: 1,
                    keyboardType: TextInputType.multiline,
                    style: Theme.of(context).textTheme.bodyMedium,
                    decoration: InputDecoration(
                      hintText: 'Insert your recipe step',
                      hintStyle: Theme.of(context).textTheme.labelLarge,
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (showDivider)
            Divider(
              height: 1,
              thickness: 1,
              color: AppTheme.crossedOutGreen,
              indent: 16,
              endIndent: 16,
            ),
        ],
      ),
    );
  }
}