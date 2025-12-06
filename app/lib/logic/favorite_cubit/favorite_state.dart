import 'package:equatable/equatable.dart';
import '../../data/models/item_model.dart';

/// Base class for all favorite states.
abstract class FavoriteState extends Equatable {
  const FavoriteState();

  @override
  List<Object?> get props => [];
}

/// Initial state before favorites are loaded.
class FavoriteInitial extends FavoriteState {
  const FavoriteInitial();
}

/// Loading state during favorite operations.
class FavoriteLoading extends FavoriteState {
  const FavoriteLoading();
}

/// Favorites loaded successfully.
class FavoriteLoaded extends FavoriteState {
  final List<ItemModel> favorites;
  final Set<int> favoriteIds;

  const FavoriteLoaded({required this.favorites, required this.favoriteIds});

  @override
  List<Object?> get props => [favorites.length, favoriteIds.length];

  /// Create a copy with updated values.
  FavoriteLoaded copyWith({List<ItemModel>? favorites, Set<int>? favoriteIds}) {
    return FavoriteLoaded(
      favorites: favorites ?? this.favorites,
      favoriteIds: favoriteIds ?? this.favoriteIds,
    );
  }

  /// Check if an item is favorited.
  bool isFavorited(int itemId) => favoriteIds.contains(itemId);
}

/// A favorite toggle operation is in progress.
class FavoriteToggling extends FavoriteState {
  final int itemId;
  final Set<int> currentFavoriteIds; // Keep track during toggle

  const FavoriteToggling({
    required this.itemId,
    required this.currentFavoriteIds,
  });

  @override
  List<Object?> get props => [itemId, currentFavoriteIds.length];

  /// Check if an item is favorited.
  bool isFavorited(int id) => currentFavoriteIds.contains(id);
}

/// An error occurred during favorite operations.
class FavoriteError extends FavoriteState {
  final String message;
  final Set<int>? previousFavoriteIds;

  const FavoriteError(this.message, {this.previousFavoriteIds});

  @override
  List<Object?> get props => [message, previousFavoriteIds?.length];
}
