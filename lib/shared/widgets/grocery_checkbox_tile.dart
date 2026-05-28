import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class GroceryCheckboxTile extends StatelessWidget {
  final String title;
  final String? measurement; // e.g., "500g", "2 tbsp"
  final bool isChecked;
  final ValueChanged<bool?> onChanged;

  const GroceryCheckboxTile({
    super.key,
    required this.title,
    required this.isChecked,
    required this.onChanged,
    this.measurement,
  });

  @override
  Widget build(BuildContext context) {
    final Color textColor = isChecked
        ? AppTheme.crossedOutGreen
        : AppTheme.bodyTextGreen;
    final TextDecoration textDecoration = isChecked
        ? TextDecoration.lineThrough
        : TextDecoration.none;

    return InkWell(
      onTap: () => onChanged(!isChecked),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        child: Row(
          children: [
            // --- CUSTOM DESIGN RADIUS CHECKBOX CONTROLLER ---
            SizedBox(
              height: 24,
              width: 24,
              child: Checkbox(
                value: isChecked,
                onChanged: onChanged,
                activeColor: AppTheme.headingGreen,
                checkColor: AppTheme.cardWhite,
                side: const BorderSide(color: AppTheme.greyAccent, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    4,
                  ), // Beautifully soft curved checkbox profile
                ),
              ),
            ),

            const SizedBox(width: 14),

            // --- INLINE ITEM ITEM TITLE ---
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: textColor,
                  decoration: textDecoration,
                  fontWeight: isChecked ? FontWeight.w400 : FontWeight.w500,
                ),
              ),
            ),

            // --- OPTIONAL TAIL MEASUREMENT DISPLAY VALUE ---
            if (measurement != null) ...[
              const SizedBox(width: 8),
              Text(
                measurement!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isChecked
                      ? AppTheme.crossedOutGreen
                      : AppTheme.greyAccent,
                  decoration: textDecoration,
                  fontWeight: isChecked ? FontWeight.w400 : FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
