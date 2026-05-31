import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final SupabaseClient _client;
  AuthRepository(this._client);

  // Call once at app startup before using Google Sign-In
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
    // Step 1: authenticate — triggers native Credential Manager sheet
    final googleUser = await GoogleSignIn.instance.authenticate();

    // Step 2: get idToken from authentication
    final idToken = googleUser.authentication.idToken;

    // Step 3: authorize scopes to get accessToken
    final clientAuth = await googleUser.authorizationClient
        .authorizeScopes(['email', 'profile']);
    final accessToken = clientAuth.accessToken;

    if (idToken == null) throw Exception('No ID token from Google');

    // Step 4: pass both tokens to Supabase
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