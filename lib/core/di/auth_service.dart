import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Abstract auth service
abstract class AuthService {
  Future<bool> get isLoggedIn;
  Future<void> login(String email, String password);
  Future<void> register(String email, String password, String fullName);
  Future<void> logout();
  Future<void> resetPassword(String email);
  String? getCurrentUserId();
}

// Auth service implementation
class AuthServiceImpl implements AuthService {
  SupabaseClient? _supabase;

  AuthServiceImpl() {
    try {
      _supabase = GetIt.instance<SupabaseClient>();
    } catch (e) {
      // Supabase not available, likely during testing
      _supabase = null;
    }
  }

  @override
  Future<bool> get isLoggedIn async {
    if (_supabase == null) return false;
    try {
      final session = _supabase?.auth.currentSession;
      return session != null;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> login(String email, String password) async {
    if (_supabase == null) return;
    try {
      await _supabase!.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      // Handle error appropriately for testing
      rethrow;
    }
  }

  @override
  Future<void> register(String email, String password, String fullName) async {
    if (_supabase == null) return;
    try {
      final response = await _supabase!.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
        },
      );

      // Create user profile
      if (response.user != null) {
        await _supabase!.from('users').insert({
          'id': response.user!.id,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });

        await _supabase!.from('businesses').insert({
          'id': response.user!.id, // Using user ID as business ID for simplicity
          'user_id': response.user!.id,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      // Handle error appropriately for testing
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    if (_supabase == null) return;
    try {
      await _supabase!.auth.signOut();
    } catch (e) {
      // Handle error appropriately for testing
      rethrow;
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    if (_supabase == null) return;
    try {
      await _supabase!.auth.resetPasswordForEmail(email);
    } catch (e) {
      // Handle error appropriately for testing
      rethrow;
    }
  }

  @override
  String? getCurrentUserId() {
    if (_supabase == null) return null;
    try {
      return _supabase!.auth.currentUser?.id;
    } catch (e) {
      return null;
    }
  }
}