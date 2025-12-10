import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/auth_repository.dart';
import 'auth_state.dart';

/// Cubit that manages authentication state.
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit({AuthRepository? authRepository})
    : _authRepository = authRepository ?? AuthRepository(),
      super(const AuthInitial());

  /// Check if user is already authenticated on app start.
  Future<void> checkAuthStatus() async {
    emit(const AuthLoading());

    try {
      if (_authRepository.isSignedIn()) {
        final userModel = await _authRepository.getCurrentUserModel();
        if (userModel != null) {
          emit(AuthAuthenticated(userModel));
        } else {
          emit(const AuthUnauthenticated());
        }
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  /// Sign in with email and password.
  Future<void> login({required String email, required String password}) async {
    emit(const AuthLoading());

    try {
      final user = await _authRepository.signIn(
        email: email,
        password: password,
      );

      if (user != null) {
        final userModel = await _authRepository.getCurrentUserModel();
        if (userModel != null) {
          emit(AuthAuthenticated(userModel));
        } else {
          emit(const AuthError('User profile not found'));
        }
      } else {
        emit(const AuthError('Invalid email or password'));
      }
    } catch (e) {
      emit(AuthError('Login failed: ${e.toString()}'));
    }
  }

  /// Register a new user.
  Future<void> register({
    required String email,
    required String password,
    required String userName,
    int? phoneNum,
    String? imageUrl,
  }) async {
    emit(const AuthLoading());

    try {
      final normalizedEmail = email.toLowerCase().trim();
      final user = await _authRepository.signUp(
        email: normalizedEmail,
        password: password,
        userName: userName,
        phoneNum: phoneNum,
        imageUrl: imageUrl,
      );

      if (user != null) {
        // Wait a moment for the session to be established
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Get user model - pass email as fallback in case currentUser isn't set yet
        final userModel = await _authRepository.getCurrentUserModel(emailFallback: normalizedEmail);
        
        if (userModel != null) {
          emit(AuthAuthenticated(userModel));
        } else {
          emit(const AuthError('Failed to load user profile after registration. Please try logging in.'));
        }
      } else {
        emit(const AuthError('Registration failed'));
      }
    } catch (e) {
      emit(AuthError('Sign up failed: ${e.toString()}'));
    }
  }

  /// Sign out the current user.
  Future<void> logout() async {
    emit(const AuthLoading());

    try {
      await _authRepository.signOut();
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthError('Logout failed: ${e.toString()}'));
    }
  }

  /// Get the current authenticated user (if any).
  /// Returns null if not in AuthAuthenticated state.
  int? get currentUserId {
    final currentState = state;
    if (currentState is AuthAuthenticated) {
      return currentState.user.userId;
    }
    return null;
  }
}
