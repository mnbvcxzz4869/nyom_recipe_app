import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

enum CustomButtonType { primary, secondary, dashed }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final CustomButtonType type;
  final Widget? icon;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = CustomButtonType.primary,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color getBackgroundColor() {
      if (onPressed == null) return theme.disabledColor;
      switch (type) {
        case CustomButtonType.primary:
          return theme.colorScheme.secondary;
        case CustomButtonType.secondary:
          return theme.colorScheme.onPrimary;
        case CustomButtonType.dashed:
          return theme.colorScheme.onPrimary;
      }
    }

    Color getForegroundColor() {
      if (onPressed == null) return theme.disabledColor.withValues(alpha: 0.6);
      switch (type) {
        case CustomButtonType.primary:
        case CustomButtonType.secondary:
          return theme.colorScheme.primary;
        case CustomButtonType.dashed:
          return AppTheme.crossedOutGreen;
      }
    }

    BorderSide getBorderSide() {
      return BorderSide.none;
    }

    double getElevation() {
      if (onPressed == null) return 0;
      return 2.0;
    }

    if (type == CustomButtonType.primary ||
        type == CustomButtonType.secondary) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: getBackgroundColor(),
            foregroundColor: getForegroundColor(),
            minimumSize: const Size.fromHeight(52),
            side: getBorderSide(),
            elevation: getElevation(),
            shadowColor: theme.shadowColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[icon!, const SizedBox(width: 12)],
              Text(text, style: theme.textTheme.titleMedium),
            ],
          ),
        ),
      );
    }

    return DottedBorder(
      options: RoundedRectDottedBorderOptions(
        color: AppTheme.crossedOutGreen,
        strokeWidth: 1,
        radius: const Radius.circular(
          8,
        ), 
        dashPattern: const [6, 2],
      ),
      child: Material(
        color: getBackgroundColor(),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: double.infinity,
            height: 60,
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[icon!, const SizedBox(width: 12)],
                Text(
                  text,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: 16,
                    color: getForegroundColor(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
