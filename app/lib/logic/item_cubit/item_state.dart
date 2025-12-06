import 'package:equatable/equatable.dart';
import '../../data/models/item_model.dart';

/// Base class for all item states.
abstract class ItemState extends Equatable {
  const ItemState();

  @override
  List<Object?> get props => [];
}

/// Initial state before items are loaded.
class ItemInitial extends ItemState {
  const ItemInitial();
}

/// Loading state during item operations.
class ItemLoading extends ItemState {
  const ItemLoading();
}

/// Items loaded successfully.
class ItemLoaded extends ItemState {
  final List<ItemModel> allItems;
  final List<ItemModel> filteredItems;
  final String? activeCategory;
  final String? searchQuery;

  const ItemLoaded({
    required this.allItems,
    required this.filteredItems,
    this.activeCategory,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [
    allItems.length,
    filteredItems.length,
    activeCategory,
    searchQuery,
  ];

  /// Create a copy with updated values.
  ItemLoaded copyWith({
    List<ItemModel>? allItems,
    List<ItemModel>? filteredItems,
    String? activeCategory,
    String? searchQuery,
  }) {
    return ItemLoaded(
      allItems: allItems ?? this.allItems,
      filteredItems: filteredItems ?? this.filteredItems,
      activeCategory: activeCategory ?? this.activeCategory,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

/// Item operation in progress (create, update, delete).
class ItemOperationInProgress extends ItemState {
  final String operation; // 'creating', 'updating', 'deleting'

  const ItemOperationInProgress(this.operation);

  @override
  List<Object?> get props => [operation];
}

/// Item operation completed successfully.
class ItemOperationSuccess extends ItemState {
  final String message;
  final ItemModel? item; // The created/updated item (if applicable)

  const ItemOperationSuccess(this.message, {this.item});

  @override
  List<Object?> get props => [message, item?.itemId];
}

/// An error occurred during item operations.
class ItemError extends ItemState {
  final String message;
  final List<ItemModel>? previousItems; // Keep previous items if available

  const ItemError(this.message, {this.previousItems});

  @override
  List<Object?> get props => [message, previousItems?.length];
}
