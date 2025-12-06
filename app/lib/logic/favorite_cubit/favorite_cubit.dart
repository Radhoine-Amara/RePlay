import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/favorite_repository.dart';
import 'favorite_state.dart';

/// Cubit that manages user favorites state.
class FavoriteCubit extends Cubit<FavoriteState> {
  final FavoriteRepository _favoriteRepository;

  FavoriteCubit({FavoriteRepository? favoriteRepository})
    : _favoriteRepository = favoriteRepository ?? FavoriteRepository(),
      super(const FavoriteInitial());

  /// Load all favorites for a user.
  Future<void> loadFavorites(int userId) async {
    emit(const FavoriteLoading());

    try {
      final favorites = await _favoriteRepository.getUserFavorites(userId);
      final favoriteIds = favorites
          .where((item) => item.itemId != null)
          .map((item) => item.itemId!)
          .toSet();

      emit(FavoriteLoaded(favorites: favorites, favoriteIds: favoriteIds));
    } catch (e) {
      emit(FavoriteError('Error loading favorites: ${e.toString()}'));
    }
  }

  /// Toggle favorite status for an item.
  Future<void> toggleFavorite(int userId, int itemId) async {
    final currentState = state;
    Set<int> currentIds = {};

    if (currentState is FavoriteLoaded) {
      currentIds = Set.from(currentState.favoriteIds);
    } else if (currentState is FavoriteToggling) {
      currentIds = Set.from(currentState.currentFavoriteIds);
    }

    // Optimistic update - toggle locally first
    final wasFavorited = currentIds.contains(itemId);
    if (wasFavorited) {
      currentIds.remove(itemId);
    } else {
      currentIds.add(itemId);
    }

    emit(FavoriteToggling(itemId: itemId, currentFavoriteIds: currentIds));

    try {
      final success = await _favoriteRepository.toggleFavorite(userId, itemId);

      if (success) {
        // Reload favorites to get updated list
        final favorites = await _favoriteRepository.getUserFavorites(userId);
        final favoriteIds = favorites
            .where((item) => item.itemId != null)
            .map((item) => item.itemId!)
            .toSet();

        emit(FavoriteLoaded(favorites: favorites, favoriteIds: favoriteIds));
      } else {
        // Revert on failure
        if (wasFavorited) {
          currentIds.add(itemId);
        } else {
          currentIds.remove(itemId);
        }
        emit(
          FavoriteError(
            'Failed to toggle favorite',
            previousFavoriteIds: currentIds,
          ),
        );
      }
    } catch (e) {
      // Revert on error
      if (wasFavorited) {
        currentIds.add(itemId);
      } else {
        currentIds.remove(itemId);
      }
      emit(
        FavoriteError(
          'Error toggling favorite: ${e.toString()}',
          previousFavoriteIds: currentIds,
        ),
      );
    }
  }

  /// Add item to favorites.
  Future<bool> addToFavorites(int userId, int itemId) async {
    try {
      final success = await _favoriteRepository.addToFavorites(userId, itemId);
      if (success) {
        await loadFavorites(userId);
      }
      return success;
    } catch (e) {
      emit(FavoriteError('Error adding to favorites: ${e.toString()}'));
      return false;
    }
  }

  /// Remove item from favorites.
  Future<bool> removeFromFavorites(int userId, int itemId) async {
    try {
      final success = await _favoriteRepository.removeFromFavorites(
        userId,
        itemId,
      );
      if (success) {
        await loadFavorites(userId);
      }
      return success;
    } catch (e) {
      emit(FavoriteError('Error removing from favorites: ${e.toString()}'));
      return false;
    }
  }

  /// Check if an item is favorited (from current state).
  bool isFavorited(int itemId) {
    final currentState = state;
    if (currentState is FavoriteLoaded) {
      return currentState.isFavorited(itemId);
    } else if (currentState is FavoriteToggling) {
      return currentState.isFavorited(itemId);
    }
    return false;
  }

  /// Get the set of favorite item IDs.
  Set<int> get favoriteIds {
    final currentState = state;
    if (currentState is FavoriteLoaded) {
      return currentState.favoriteIds;
    } else if (currentState is FavoriteToggling) {
      return currentState.currentFavoriteIds;
    }
    return {};
  }
}
