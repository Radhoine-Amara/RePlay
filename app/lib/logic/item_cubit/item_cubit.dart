import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/item_repository.dart';
import '../../data/models/item_model.dart';
import 'item_state.dart';

/// Cubit that manages item/listing state.
class ItemCubit extends Cubit<ItemState> {
  final ItemRepository _itemRepository;

  ItemCubit({ItemRepository? itemRepository})
    : _itemRepository = itemRepository ?? ItemRepository(),
      super(const ItemInitial());

  /// Load all items from the database.
  Future<void> loadAllItems() async {
    emit(const ItemLoading());

    try {
      final items = await _itemRepository.getAllItems();
      emit(ItemLoaded(allItems: items, filteredItems: items));
    } catch (e) {
      emit(ItemError('Error loading items: ${e.toString()}'));
    }
  }

  /// Load items for a specific user.
  Future<void> loadUserItems(int userId) async {
    emit(const ItemLoading());

    try {
      final items = await _itemRepository.getItemsByUser(userId);
      emit(ItemLoaded(allItems: items, filteredItems: items));
    } catch (e) {
      emit(ItemError('Error loading user items: ${e.toString()}'));
    }
  }

  /// Filter items by category.
  void filterByCategory(String? category) {
    final currentState = state;
    if (currentState is ItemLoaded) {
      List<ItemModel> filtered;

      if (category == null || category.toLowerCase() == 'all') {
        filtered = currentState.allItems;
      } else {
        filtered = currentState.allItems
            .where(
              (item) => item.category?.toLowerCase() == category.toLowerCase(),
            )
            .toList();
      }

      // Apply search query if exists
      if (currentState.searchQuery != null &&
          currentState.searchQuery!.isNotEmpty) {
        filtered = _applySearchFilter(filtered, currentState.searchQuery!);
      }

      emit(
        currentState.copyWith(
          filteredItems: filtered,
          activeCategory: category,
        ),
      );
    }
  }

  /// Search items by query string.
  void searchItems(String query) {
    final currentState = state;
    if (currentState is ItemLoaded) {
      List<ItemModel> baseItems;

      // Start with category-filtered items or all items
      if (currentState.activeCategory != null &&
          currentState.activeCategory!.toLowerCase() != 'all') {
        baseItems = currentState.allItems
            .where(
              (item) =>
                  item.category?.toLowerCase() ==
                  currentState.activeCategory!.toLowerCase(),
            )
            .toList();
      } else {
        baseItems = currentState.allItems;
      }

      // Apply search filter
      final filtered = query.isEmpty
          ? baseItems
          : _applySearchFilter(baseItems, query);

      emit(currentState.copyWith(filteredItems: filtered, searchQuery: query));
    }
  }

  List<ItemModel> _applySearchFilter(List<ItemModel> items, String query) {
    final lowerQuery = query.toLowerCase();
    return items
        .where(
          (item) =>
              item.title.toLowerCase().contains(lowerQuery) ||
              (item.description?.toLowerCase().contains(lowerQuery) ?? false) ||
              (item.platform?.toLowerCase().contains(lowerQuery) ?? false),
        )
        .toList();
  }

  /// Create a new item.
  Future<ItemModel?> createItem(ItemModel item, {File? imageFile}) async {
    emit(const ItemOperationInProgress('creating'));

    try {
      String? imageUrl = item.imageUrl;

      // Upload image if provided
      if (imageFile != null) {
        imageUrl = await _itemRepository.uploadItemImage(imageFile);
        if (imageUrl == null) {
          emit(const ItemError('Failed to upload image'));
          return null;
        }
      }

      // Create item with image URL
      final newItem = ItemModel(
        title: item.title,
        description: item.description,
        type: item.type,
        category: item.category,
        platform: item.platform,
        price: item.price,
        userId: item.userId,
        status: item.status,
        imageUrl: imageUrl,
      );

      final created = await _itemRepository.createItem(newItem);

      if (created != null) {
        emit(ItemOperationSuccess('Item created successfully', item: created));
        return created;
      } else {
        emit(const ItemError('Failed to create item'));
        return null;
      }
    } catch (e) {
      emit(ItemError('Error creating item: ${e.toString()}'));
      return null;
    }
  }

  /// Update an existing item.
  Future<bool> updateItem(
    int itemId,
    Map<String, dynamic> updates, {
    File? imageFile,
  }) async {
    emit(const ItemOperationInProgress('updating'));

    try {
      // Upload new image if provided
      if (imageFile != null) {
        final imageUrl = await _itemRepository.uploadItemImage(imageFile);
        if (imageUrl != null) {
          updates['image_url'] = imageUrl;
        }
      }

      final success = await _itemRepository.updateItem(itemId, updates);

      if (success) {
        emit(const ItemOperationSuccess('Item updated successfully'));
        return true;
      } else {
        emit(const ItemError('Failed to update item'));
        return false;
      }
    } catch (e) {
      emit(ItemError('Error updating item: ${e.toString()}'));
      return false;
    }
  }

  /// Delete an item.
  Future<bool> deleteItem(int itemId) async {
    emit(const ItemOperationInProgress('deleting'));

    try {
      final success = await _itemRepository.deleteItem(itemId);

      if (success) {
        emit(const ItemOperationSuccess('Item deleted successfully'));
        return true;
      } else {
        emit(const ItemError('Failed to delete item'));
        return false;
      }
    } catch (e) {
      emit(ItemError('Error deleting item: ${e.toString()}'));
      return false;
    }
  }

  /// Refresh items (reload from database).
  Future<void> refreshItems() async {
    final currentState = state;

    try {
      final items = await _itemRepository.getAllItems();

      if (currentState is ItemLoaded) {
        // Preserve current filters
        List<ItemModel> filtered = items;

        if (currentState.activeCategory != null &&
            currentState.activeCategory!.toLowerCase() != 'all') {
          filtered = items
              .where(
                (item) =>
                    item.category?.toLowerCase() ==
                    currentState.activeCategory!.toLowerCase(),
              )
              .toList();
        }

        if (currentState.searchQuery != null &&
            currentState.searchQuery!.isNotEmpty) {
          filtered = _applySearchFilter(filtered, currentState.searchQuery!);
        }

        emit(
          ItemLoaded(
            allItems: items,
            filteredItems: filtered,
            activeCategory: currentState.activeCategory,
            searchQuery: currentState.searchQuery,
          ),
        );
      } else {
        emit(ItemLoaded(allItems: items, filteredItems: items));
      }
    } catch (e) {
      print('Error refreshing items: $e');
      // Keep current state on error
    }
  }
}
