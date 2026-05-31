import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/supabase_service.dart';
import '../models/app_user.dart';
import '../repositories/auth_repository.dart';
import '../repositories/user_repository.dart';

final authRepositoryProvider = Provider((ref) =>
    AuthRepository(Supabase.instance.client));

final userRepositoryProvider = Provider((ref) =>
    UserRepository(Supabase.instance.client));

final authStateProvider = StreamProvider<AuthState>((ref) =>
    ref.read(authRepositoryProvider).authStateChanges);

// Fetches and caches the current user's profile
final currentUserProvider = FutureProvider<AppUser?>((ref) async {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (state) async {
      if (state.session == null) return null;
      return ref.read(userRepositoryProvider).fetchCurrentUser();
    },
    loading: () => null,
    error: (_, __) => null,
  );
});