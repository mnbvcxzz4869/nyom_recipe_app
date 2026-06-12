import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class AppLoadingOverlay extends StatelessWidget {
  final String? label;

  const AppLoadingOverlay({super.key, this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ColoredBox(
      color: AppTheme.baseBackground,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Theme(
              data: theme.copyWith(
                progressIndicatorTheme: ProgressIndicatorThemeData(
                  color: theme.colorScheme.primary,
                  circularTrackColor: theme.colorScheme.secondary,
                  strokeWidth: 4,
                  strokeCap: StrokeCap.round,
                ),
              ),
              child: const SizedBox(
                width: 64,
                height: 64,
                child: CircularProgressIndicator(),
              ),
            ),
            if (label != null) ...[
              const SizedBox(height: 20),
              Text(
                label!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
