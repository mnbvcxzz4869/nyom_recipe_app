import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class AppBottomNav extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppBottomNav({super.key, required this.navigationShell});

  void _onTabSelected(BuildContext context, int index) {
    if (index == 2) {
      context.push('/ai-parse');
      return;
    }

    final int targetBranchIndex = index > 2 ? index - 1 : index;

    navigationShell.goBranch(
      targetBranchIndex,
      initialLocation: targetBranchIndex == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    int currentVisualIndex = navigationShell.currentIndex;
    if (currentVisualIndex >= 2) {
      currentVisualIndex += 1;
    }

    return Scaffold(
      extendBody: true,
      backgroundColor: AppTheme.baseBackground,
      body: navigationShell,
      bottomNavigationBar: SafeArea(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: IntrinsicWidth(
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 8.0,
              ),
              decoration: BoxDecoration(
                color: AppTheme.cardWhite,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.greyAccent.withValues(alpha: 0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTabIcon(
                    context,
                    0,
                    Icons.home_rounded,
                    currentVisualIndex,
                  ),
                  const SizedBox(width: 16), // 16px exact gap between items

                  _buildTabIcon(
                    context,
                    1,
                    Icons.menu_book_rounded,
                    currentVisualIndex,
                  ),
                  const SizedBox(width: 16),

                  // Unified Center Plus Button (No labels, no special circle decoration)
                  _buildTabIcon(
                    context,
                    2,
                    Icons.add_rounded,
                    currentVisualIndex,
                  ),
                  const SizedBox(width: 16),

                  _buildTabIcon(
                    context,
                    3,
                    Icons.event_note_rounded,
                    currentVisualIndex,
                  ),
                  const SizedBox(width: 16),

                  _buildTabIcon(
                    context,
                    4,
                    Icons.shopping_cart_rounded,
                    currentVisualIndex,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabIcon(
    BuildContext context,
    int index,
    IconData itemIcon,
    int currentVisualIndex,
  ) {
    final bool isSelected = index == currentVisualIndex;
    final Color activeColor = AppTheme.headingGreen;
    final Color inactiveColor = AppTheme.headingGreen;

    return InkWell(
      onTap: () => _onTabSelected(context, index),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 48,
        width: 48,
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.warmYellow : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Icon(
            itemIcon,
            color: isSelected ? activeColor : inactiveColor,
            size: itemIcon == Icons.add_rounded
                ? 32
                : 24, // Icon sizing scales cleanly inside the 48x48 box
          ),
        ),
      ),
    );
  }
}
