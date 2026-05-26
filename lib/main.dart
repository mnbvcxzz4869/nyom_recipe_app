import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: NyomApp()));
}

class NyomApp extends StatelessWidget {
  const NyomApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Crucial swap to .router initialization format
    return MaterialApp.router(
      title: 'Nyom',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter, // Injects your clean GoRouter mapping profile
    );
  }
}
