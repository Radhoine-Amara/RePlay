// FILE: lib/services/auth_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';
import '../models/user_model.dart';
import 'user_service.dart';

class AuthService {
  final _supabase = SupabaseService.client;
  final _userService = UserService();

  // Sign Up - Creates auth user AND database user record
  Future<User?> signUp({
    required String email,
    required String password,
    required String userName,
    int? phoneNum,
    String? imageUrl,
  }) async {
    try {
      // 1. Create auth user
      final authResponse = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (authResponse.user != null) {
        // 2. Create user record in database
        final userModel = UserModel(
          userName: userName,
          email: email.toLowerCase().trim(),
          phoneNum: phoneNum,
          password: password, // In production, don't store plain passwords!
          imageUrl: imageUrl,
        );

        final createdUser = await _userService.createUser(userModel);
        if (createdUser == null) {
          throw Exception('Failed to create user profile in database');
        }
        
        return authResponse.user;
      }
      
      throw Exception('Failed to create authentication user');
    } catch (e) {
      print('Error signing up: $e');
      rethrow;
    }
  }

  // Sign In
  Future<User?> signIn(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      return response.user;
    } catch (e) {
      print('Error signing in: $e');
      rethrow;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  // Get Current User
  User? getCurrentUser() {
    return _supabase.auth.currentUser;
  }

  // Check if user is signed in
  bool isSignedIn() {
    return _supabase.auth.currentUser != null;
  }

  // Listen to auth state changes
  Stream<AuthState> get authStateChanges {
    return _supabase.auth.onAuthStateChange;
  }

  // Get user ID
  String? getUserId() {
    return _supabase.auth.currentUser?.id;
  }

  // Reset Password
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      print('Error resetting password: $e');
      rethrow;
    }
  }
}