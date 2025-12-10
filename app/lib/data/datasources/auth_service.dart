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
    final normalizedEmail = email.toLowerCase().trim();
    try {
      // 1. Create auth user first
      final authResponse = await _supabase.auth.signUp(
        email: normalizedEmail,
        password: password,
      );

      if (authResponse.user == null) {
        throw Exception('Failed to create authentication user');
      }
      
      final authUser = authResponse.user!;

      // 2. Create user record in database
      try {
        final userModel = UserModel(
          userName: userName,
          email: normalizedEmail,
          phoneNum: phoneNum,
          password: password,
          imageUrl: imageUrl,
        );

        final createdUser = await _userService.createUser(userModel);
        if (createdUser == null) {
          throw Exception('Database returned null when creating user');
        }
        
        // 3. Auto-login the user after registration
        try {
          final loginResponse = await _supabase.auth.signInWithPassword(
            email: normalizedEmail,
            password: password,
          );
          if (loginResponse.user != null) {
            return loginResponse.user;
          }
        } catch (loginError) {
          print('Warning: Auto-login failed after signup: $loginError');
          // Even if auto-login fails, return the created auth user
          return authUser;
        }
        
        return authUser;
      } catch (dbError) {
        print('Warning: Database user creation failed after auth signup: $dbError');
        throw Exception('Failed to create user profile: ${dbError.toString()}');
      }
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

  // Get Current User's Email (tries multiple sources)
  String? getCurrentUserEmail() {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;
    
    // Try email first
    if (user.email != null && user.email!.isNotEmpty) {
      return user.email;
    }
    
    // Try user metadata
    if (user.userMetadata != null && user.userMetadata!['email'] != null) {
      return user.userMetadata!['email'] as String;
    }
    
    // Try from user id (last resort - not reliable)
    return null;
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