import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_user.dart';
import '../repositories/auth_repository.dart';
import '../repositories/user_repository.dart';

final authRepositoryProvider = Provider(
  (ref) => AuthRepository(Supabase.instance.client),
);

final userRepositoryProvider = Provider(
  (ref) => UserRepository(Supabase.instance.client),
);

final authStateProvider = StreamProvider<AuthState>(
  (ref) => ref.read(authRepositoryProvider).authStateChanges,
);

final currentUserProvider = FutureProvider<AppUser?>((ref) async {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (state) async {
      if (state.session == null) return null;
      return ref.read(userRepositoryProvider).fetchCurrentUser();
    },
    loading: () => null,
    error: (_, _) => null,
  );
});

final userCreatedAtProvider = FutureProvider<DateTime>((ref) async {
  final user = await ref.watch(currentUserProvider.future);
  if (user != null) return user.signupDate;
  final now = DateTime.now();
  return now.subtract(Duration(days: now.weekday - 1));
});
