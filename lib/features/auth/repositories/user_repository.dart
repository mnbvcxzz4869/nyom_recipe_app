import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_user.dart';

class UserRepository {
  final SupabaseClient _client;
  UserRepository(this._client);

  Future<AppUser> fetchCurrentUser() async {
    final userId = _client.auth.currentUser!.id;
    final response = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();

    // email comes from auth, not profiles table
    return AppUser.fromJson({
      ...response,
      'email': _client.auth.currentUser!.email ?? '',
    });
  }

  Future<void> updateUsername(String username) async {
    final userId = _client.auth.currentUser!.id;
    await _client
        .from('profiles')
        .update({'username': username})
        .eq('id', userId);
  }
}