import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/repositories/item_repository.dart';
import '../../data/repositories/favorite_repository.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/models/user_model.dart';
import 'profile_state.dart';

/// Cubit that manages user profile state.
class ProfileCubit extends Cubit<ProfileState> {
  final UserRepository _userRepository;
  final ItemRepository _itemRepository;
  final FavoriteRepository _favoriteRepository;
  final AuthRepository _authRepository;

  ProfileCubit({
    UserRepository? userRepository,
    ItemRepository? itemRepository,
    FavoriteRepository? favoriteRepository,
    AuthRepository? authRepository,
  }) : _userRepository = userRepository ?? UserRepository(),
       _itemRepository = itemRepository ?? ItemRepository(),
       _favoriteRepository = favoriteRepository ?? FavoriteRepository(),
       _authRepository = authRepository ?? AuthRepository(),
       super(const ProfileInitial());

  /// Load the current user's profile with their listings and favorites.
  Future<void> loadProfile() async {
    emit(const ProfileLoading());

    try {
      final userModel = await _authRepository.getCurrentUserModel();

      if (userModel == null || userModel.userId == null) {
        emit(const ProfileError('User not found'));
        return;
      }

      // Load user's listings and favorites in parallel
      final results = await Future.wait([
        _itemRepository.getItemsByUser(userModel.userId!),
        _favoriteRepository.getUserFavorites(userModel.userId!),
      ]);

      emit(
        ProfileLoaded(
          user: userModel,
          myListings: results[0],
          myFavorites: results[1],
        ),
      );
    } catch (e) {
      emit(ProfileError('Error loading profile: ${e.toString()}'));
    }
  }

  /// Load profile for a specific user by ID (for viewing other users).
  Future<void> loadUserProfile(int userId) async {
    emit(const ProfileLoading());

    try {
      final userModel = await _userRepository.getUserById(userId);

      if (userModel == null) {
        emit(const ProfileError('User not found'));
        return;
      }

      final listings = await _itemRepository.getItemsByUser(userId);

      emit(
        ProfileLoaded(
          user: userModel,
          myListings: listings,
          myFavorites: const [],
        ),
      );
    } catch (e) {
      emit(ProfileError('Error loading profile: ${e.toString()}'));
    }
  }

  /// Update user profile with the given updates.
  Future<void> updateProfile(Map<String, dynamic> updates) async {
    final currentState = state;
    UserModel? currentUser;

    if (currentState is ProfileLoaded) {
      currentUser = currentState.user;
      emit(ProfileUpdating(currentUser));
    }

    try {
      if (currentUser == null || currentUser.userId == null) {
        emit(const ProfileError('No user to update'));
        return;
      }

      final success = await _userRepository.updateUser(
        currentUser.userId!,
        updates,
      );

      if (success) {
        // Reload the updated profile
        await loadProfile();
      } else {
        emit(ProfileError('Failed to update profile', user: currentUser));
      }
    } catch (e) {
      emit(
        ProfileError(
          'Error updating profile: ${e.toString()}',
          user: currentUser,
        ),
      );
    }
  }

  /// Upload a profile image and update the user's profile.
  Future<void> uploadProfileImage(File imageFile) async {
    final currentState = state;
    UserModel? currentUser;

    if (currentState is ProfileLoaded) {
      currentUser = currentState.user;
      emit(ProfileUpdating(currentUser));
    }

    try {
      if (currentUser == null || currentUser.userId == null) {
        emit(const ProfileError('No user to update'));
        return;
      }

      final imageUrl = await _userRepository.uploadProfileImage(
        imageFile,
        currentUser.userId!,
      );

      if (imageUrl != null) {
        await updateProfile({'imageurl': imageUrl});
      } else {
        emit(ProfileError('Failed to upload image', user: currentUser));
      }
    } catch (e) {
      emit(
        ProfileError(
          'Error uploading image: ${e.toString()}',
          user: currentUser,
        ),
      );
    }
  }

  /// Refresh just the user's listings.
  Future<void> refreshListings() async {
    final currentState = state;
    if (currentState is ProfileLoaded) {
      try {
        final listings = await _itemRepository.getItemsByUser(
          currentState.user.userId!,
        );
        emit(currentState.copyWith(myListings: listings));
      } catch (e) {
        // Keep current state on error
        print('Error refreshing listings: $e');
      }
    }
  }

  /// Refresh just the user's favorites.
  Future<void> refreshFavorites() async {
    final currentState = state;
    if (currentState is ProfileLoaded) {
      try {
        final favorites = await _favoriteRepository.getUserFavorites(
          currentState.user.userId!,
        );
        emit(currentState.copyWith(myFavorites: favorites));
      } catch (e) {
        // Keep current state on error
        print('Error refreshing favorites: $e');
      }
    }
  }

  /// Get the current user ID if available.
  int? get currentUserId {
    final currentState = state;
    if (currentState is ProfileLoaded) {
      return currentState.user.userId;
    }
    return null;
  }
}
