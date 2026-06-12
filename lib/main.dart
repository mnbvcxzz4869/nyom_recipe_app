import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nyom_recipe_app/features/auth/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );
  await AuthRepository(Supabase.instance.client).initGoogleSignIn();
  runApp(const ProviderScope(child: NyomApp()));
}

class NyomApp extends StatefulWidget {
  const NyomApp({super.key});

  @override
  State<NyomApp> createState() => _NyomAppState();
}

class _NyomAppState extends State<NyomApp> {
  late final StreamSubscription<AuthState> _authSubscription;

  @override
  void initState() {
    super.initState();
      _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      
      if (event == AuthChangeEvent.passwordRecovery) {
        appRouter.go('/reset-password');
      }
    });
  }

  @override
  void dispose() {
    _authSubscription.cancel(); 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Nyom',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter, 
    );
  }
}
