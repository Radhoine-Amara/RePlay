import 'package:supabase_flutter/supabase_flutter.dart';
import '../datasources/auth_service.dart';
import '../datasources/user_service.dart';
import '../models/user_model.dart';

/// Repository that abstracts authentication operations.
/// Acts as a single source of truth for auth-related data.
class AuthRepository {
  final AuthService _authService;
  final UserService _userService;

  AuthRepository({AuthService? authService, UserService? userService})
    : _authService = authService ?? AuthService(),
      _userService = userService ?? UserService();

  /// Sign in with email and password.
  /// Returns the authenticated User if successful.
  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    return await _authService.signIn(email, password);
  }

  /// Sign up with email, password, and user details.
  /// Creates both auth user and database user record.
  Future<User?> signUp({
    required String email,
    required String password,
    required String userName,
    int? phoneNum,
    String? imageUrl,
  }) async {
    return await _authService.signUp(
      email: email,
      password: password,
      userName: userName,
      phoneNum: phoneNum,
      imageUrl: imageUrl,
    );
  }

  /// Sign out the current user.
  Future<void> signOut() async {
    await _authService.signOut();
  }

  /// Get the currently authenticated Supabase user.
  User? getCurrentAuthUser() {
    return _authService.getCurrentUser();
  }

  /// Get the database user model for the current auth user.
  /// Optionally pass email as fallback if currentUser is not yet available.
  Future<UserModel?> getCurrentUserModel({String? emailFallback}) async {
    // Try to get email from multiple sources
    String? email = _authService.getCurrentUserEmail();
    email = email ?? emailFallback;
    
    if (email == null) return null;
    
    return await _userService.getUserByEmail(email);
  }
  
  /// Get user by email directly (useful when currentUser is not available)
  Future<UserModel?> getUserByEmail(String email) async {
    return await _userService.getUserByEmail(email);
  }

  /// Check if a user is currently signed in.
  bool isSignedIn() {
    return _authService.isSignedIn();
  }

  /// Stream of auth state changes.
  Stream<AuthState> get authStateChanges => _authService.authStateChanges;

  /// Get the current auth user's ID.
  String? getAuthUserId() {
    return _authService.getUserId();
  }

  /// Reset password for the given email.
  Future<void> resetPassword(String email) async {
    await _authService.resetPassword(email);
  }
}
