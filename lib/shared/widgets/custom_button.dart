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

    // 1. Resolve Background Color
    Color getBackgroundColor() {
      if (onPressed == null) return theme.disabledColor;
      switch (type) {
        case CustomButtonType.primary:
          return theme.colorScheme.secondary;
        case CustomButtonType.secondary:
          return theme.colorScheme.onPrimary;
        case CustomButtonType.dashed:
          return Colors.transparent;
      }
    }

    // 2. Resolve Text/Foreground Color
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
      switch (type) {
        case CustomButtonType.primary:
        case CustomButtonType.secondary:
          return BorderSide.none;
        case CustomButtonType.dashed:
          return BorderSide(
            color: theme.colorScheme.primary.withValues(alpha: 0.4),
            width: 1.5,
            style: BorderStyle.solid,
          );
      }
    }

    double getElevation() {
      if (onPressed == null) return 0;
      return 2.0;
    }

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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
}
