import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/screens/login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const ProviderScope(child: RecipeAppTest()));
}

class RecipeAppTest extends StatelessWidget {
  const RecipeAppTest({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nyom',
      debugShowCheckedModeBanner: false,

      // Injecting your updated light theme with Fraunces & Commissioner fonts
      theme: AppTheme.lightTheme,

      // Directly mounting the login page for standalone testing
      home: const LoginScreen(),
    );
  }
}
