import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nyom_recipe_app/features/grocery/screens/grocery_list_screen.dart';
import 'package:nyom_recipe_app/features/home/screens/home_screen.dart';
import 'package:nyom_recipe_app/features/recipes/models/recipe.dart';
import 'package:nyom_recipe_app/features/recipes/screens/ai_parse_screen.dart';
import 'package:nyom_recipe_app/features/recipes/screens/recipe_detail_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../shared/widgets/app_bottom_nav.dart';
import '../../features/recipes/screens/recipes_screen.dart';
import '../../features/planner/screens/weekly_planner_screen.dart';

// Temporary lightweight placeholder layouts to ensure initial compilation succeeds
class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFFDF6F0,
      ), // Matches AppTheme.baseBackground
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Fraunces',
            color: Color(0xFF2D4A3E),
          ),
        ),
      ),
      body: Center(
        child: Text(
          '$title View Screen',
          style: const TextStyle(
            fontFamily: 'Commissioner',
            fontSize: 16,
            color: Color(0xFF1E2622),
          ),
        ),
      ),
    );
  }
}

// Global router key declaration profile
final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation:
      '/login', // Boots user cleanly to your finalized Login screen
  routes: [
    // --- AUTHENTICATION FLOW ROUTING CHANNELS ---
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),

    // --- CENTER TRIGGER MODAL SHORTCUT ROUTE ---
    GoRoute(
      path: '/ai-parse',
      parentNavigatorKey:
          _rootNavigatorKey, // Overlay modal sheet on top of everything
      builder: (context, state) => const AiParseScreen(),
    ),

    GoRoute(
      path: '/recipe-detail',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final recipe = state.extra as Recipe;
        return RecipeDetailScreen(recipe: recipe);
      },
    ),

    // --- PERSISTENT 4-BRANCH BOTTOM NAVIGATION SHELL ---
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppBottomNav(navigationShell: navigationShell);
      },
      branches: [
        // Index Branch 0: Home Feed View
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),

        // Index Branch 1: Recipes Repository List View
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/recipes',
              builder: (context, state) => const RecipesScreen(),
            ),
          ],
        ),

        // Index Branch 2: Meal Scheduler Calendar View
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/planner',
              builder: (context, state) => const WeeklyPlannerScreen(),
            ),
          ],
        ),

        // Index Branch 3: Compiled Shopping Grocery View
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/grocery',
              builder: (context, state) => const GroceryListScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
