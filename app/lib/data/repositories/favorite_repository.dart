import '../datasources/favorite_service.dart';
import '../models/item_model.dart';

/// Repository that abstracts favorite operations.
class FavoriteRepository {
  final FavoriteService _favoriteService;

  FavoriteRepository({FavoriteService? favoriteService})
    : _favoriteService = favoriteService ?? FavoriteService();

  /// Add an item to user's favorites.
  Future<bool> addToFavorites(int userId, int itemId) async {
    return await _favoriteService.addToFavorites(userId, itemId);
  }

  /// Remove an item from user's favorites.
  Future<bool> removeFromFavorites(int userId, int itemId) async {
    return await _favoriteService.removeFromFavorites(userId, itemId);
  }

  /// Toggle favorite status for an item.
  /// Returns true if operation was successful.
  Future<bool> toggleFavorite(int userId, int itemId) async {
    return await _favoriteService.toggleFavorite(userId, itemId);
  }

  /// Get all favorite items for a user.
  Future<List<ItemModel>> getUserFavorites(int userId) async {
    return await _favoriteService.getUserFavorites(userId);
  }

  /// Check if an item is favorited by a user.
  Future<bool> isFavorited(int userId, int itemId) async {
    return await _favoriteService.isFavorited(userId, itemId);
  }
}
