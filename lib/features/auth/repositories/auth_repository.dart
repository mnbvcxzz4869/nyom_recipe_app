import '../../../core/errors/app_exceptions.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final SupabaseClient _client;
  AuthRepository(this._client);

  Future<void> initGoogleSignIn() async {
    await GoogleSignIn.instance.initialize(
      serverClientId: dotenv.env['WEB_CLIENT_ID'] ?? '',
    );
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String username,
  }) =>
      _client.auth.signUp(
        email: email,
        password: password,
        data: {'username': username},
      );

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) =>
      _client.auth.signInWithPassword(email: email, password: password);

  Future<AuthResponse> signInWithGoogle() async {
    final googleUser = await GoogleSignIn.instance.authenticate();

    final idToken = googleUser.authentication.idToken;

    final clientAuth = await googleUser.authorizationClient
        .authorizeScopes(['email', 'profile']);
    final accessToken = clientAuth.accessToken;

    if (idToken == null) throw const GoogleAuthException('No ID token received');

    return _client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );
  }

  Future<void> signOut() async {
    await GoogleSignIn.instance.signOut();
    await _client.auth.signOut();
  }

  Session? get currentSession => _client.auth.currentSession;
  User? get currentUser => _client.auth.currentUser;
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
}