import 'package:actibind/core/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  AuthService._();

  static SupabaseClient get _supabase => SupabaseService.client;

  static User? get currentUser => _supabase.auth.currentUser;
  static Session? get currentSession => _supabase.auth.currentSession;
  static Stream<AuthState> get authStateChanges =>
      _supabase.auth.onAuthStateChange;

  static Future<bool> validateCurrentSession() async {
    if (currentSession == null) return false;

    try {
      final response = await _supabase.auth.getUser();
      return response.user != null;
    } on AuthException {
      await _supabase.auth.signOut(scope: SignOutScope.local);
      return false;
    } catch (_) {
      // Keep a valid cached session when the device is temporarily offline.
      return currentSession != null;
    }
  }

  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      return await _supabase.auth.signUp(
        email: email.trim(),
        password: password,
        data: {
          if (fullName != null && fullName.trim().isNotEmpty)
            'full_name': fullName.trim(),
        },
      );
    } on AuthException {
      rethrow;
    } catch (error) {
      throw Exception('Registration failed: $error');
    }
  }

  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
    } on AuthException {
      rethrow;
    } catch (error) {
      throw Exception('Sign-in failed: $error');
    }
  }

  static Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } on AuthException {
      rethrow;
    } catch (error) {
      throw Exception('Sign-out failed: $error');
    }
  }

  static Future<void> resetPassword({required String email}) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email.trim());
    } on AuthException {
      rethrow;
    } catch (error) {
      throw Exception('Password reset failed: $error');
    }
  }
}
