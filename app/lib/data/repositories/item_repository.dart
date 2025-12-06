import 'dart:io';
import '../datasources/item_service.dart';
import '../datasources/supabase_service.dart';
import '../models/item_model.dart';

/// Repository that abstracts item/listing operations.
class ItemRepository {
  final ItemService _itemService;

  ItemRepository({ItemService? itemService})
    : _itemService = itemService ?? ItemService();

  /// Create a new item listing.
  Future<ItemModel?> createItem(ItemModel item) async {
    return await _itemService.createItem(item);
  }

  /// Get all items from the database.
  Future<List<ItemModel>> getAllItems() async {
    return await _itemService.getAllItems();
  }

  /// Get a specific item by ID.
  Future<ItemModel?> getItemById(int itemId) async {
    return await _itemService.getItemById(itemId);
  }

  /// Get all items for a specific user.
  Future<List<ItemModel>> getItemsByUser(int userId) async {
    return await _itemService.getItemsByUser(userId);
  }

  /// Get items by type (sell, trade, rent).
  Future<List<ItemModel>> getItemsByType(String type) async {
    return await _itemService.getItemsByType(type);
  }

  /// Get items by category.
  Future<List<ItemModel>> getItemsByCategory(String category) async {
    return await _itemService.getItemsByCategory(category);
  }

  /// Search items by query string.
  Future<List<ItemModel>> searchItems(String query) async {
    return await _itemService.searchItems(query);
  }

  /// Update an existing item.
  Future<bool> updateItem(int itemId, Map<String, dynamic> updates) async {
    return await _itemService.updateItem(itemId, updates);
  }

  /// Delete an item.
  Future<bool> deleteItem(int itemId) async {
    return await _itemService.deleteItem(itemId);
  }

  /// Upload an item image to Supabase Storage.
  /// Returns the public URL of the uploaded image.
  Future<String?> uploadItemImage(File imageFile) async {
    try {
      final fileName = 'item_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = 'items/$fileName';

      await SupabaseService.client.storage
          .from('item-images')
          .upload(filePath, imageFile);

      final publicUrl = SupabaseService.client.storage
          .from('item-images')
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      print('Error uploading item image: $e');
      return null;
    }
  }
}
