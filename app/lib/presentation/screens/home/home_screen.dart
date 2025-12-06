// FILE: lib/presentation/screens/home/home_screen.dart

import 'package:flutter/material.dart';
import '../../../data/models/item_model.dart';
import '../../../data/datasources/item_service.dart';
import '../../../data/datasources/auth_service.dart';
import '../../../data/datasources/favorite_service.dart';
import '../../../data/datasources/user_service.dart';
import 'product_page_screen.dart';
import '../item/add_listing_screen.dart';
import '../profile_screen.dart';
import '../item/edit_item_screen.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ItemService _itemService = ItemService();
  final AuthService _authService = AuthService();
  final FavoriteService _favoriteService = FavoriteService();
  final UserService _userService = UserService();

  int _currentIndex = 0;
  int _activeCategoryIndex = 0;

  List<ItemModel> _allItems = [];
  List<ItemModel> _displayedItems = [];
  bool _isLoading = true;
  int? _currentUserId;
  Set<int> _favoritedItemIds = {};

  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    AppStrings.all,
    AppStrings.games,
    AppStrings.consoles,
    AppStrings.accessories,
    AppStrings.electronics,
  ];

  @override
  void initState() {
    super.initState();
    _initializeUser();
    _loadItems();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initializeUser() async {
    try {
      final authUser = _authService.getCurrentUser();
      if (authUser != null) {
        final dbUser = await _userService.getUserByEmail(authUser.email!);
        if (dbUser != null) {
          setState(() {
            _currentUserId = dbUser.userId;
          });
          await _loadFavorites();
        }
      }
    } catch (e) {
      print('Error getting user ID: $e');
    }
  }

  Future<void> _loadFavorites() async {
    if (_currentUserId == null) return;
    try {
      final favorites = await _favoriteService.getUserFavorites(
        _currentUserId!,
      );
      setState(() {
        _favoritedItemIds = favorites
            .where((item) => item.itemId != null)
            .map((item) => item.itemId!)
            .toSet();
      });
    } catch (e) {
      print('Error loading favorites: $e');
    }
  }

  Future<void> _loadItems() async {
    setState(() => _isLoading = true);

    try {
      _allItems = await _itemService.getAllItems();
      _filterItems();
    } catch (e) {
      print('Error loading items: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading items: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _filterItems() {
    setState(() {
      if (_activeCategoryIndex == 0) {
        // "All" category (first in list)
        _displayedItems = _allItems;
      } else {
        final category = _categories[_activeCategoryIndex];
        _displayedItems = _allItems
            .where(
              (item) => item.category?.toLowerCase() == category.toLowerCase(),
            )
            .toList();
      }

      // Apply search filter if there's a query
      if (_searchController.text.isNotEmpty) {
        _searchItems(_searchController.text);
      }
    });
  }

  void _searchItems(String query) {
    setState(() {
      if (query.isEmpty) {
        _filterItems();
      } else {
        _displayedItems = _allItems
            .where(
              (item) =>
                  item.title.toLowerCase().contains(query.toLowerCase()) ||
                  (item.description?.toLowerCase().contains(
                        query.toLowerCase(),
                      ) ??
                      false),
            )
            .toList();
      }
    });
  }

  Future<void> _toggleFavorite(int itemId) async {
    if (_currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to add favorites'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final wasInFavorites = _favoritedItemIds.contains(itemId);
      await _favoriteService.toggleFavorite(_currentUserId!, itemId);

      setState(() {
        if (wasInFavorites) {
          _favoritedItemIds.remove(itemId);
        } else {
          _favoritedItemIds.add(itemId);
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              wasInFavorites ? 'Removed from favorites' : 'Added to favorites',
            ),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print('Error toggling favorite: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _buildCurrentScreen(),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildCurrentScreen() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return AddListingScreen(
          onItemCreated: (newItem) {
            // Add new item to list immediately
            setState(() {
              _allItems.insert(0, newItem);
              _filterItems();
            });
            // Switch back to home tab
            setState(() => _currentIndex = 0);
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Listing created successfully!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          },
        );
      case 2:
        return const ProfileScreen(); // This now shows the profile view with tabs
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadItems,
        color: const Color(0xFF9C4DFF),
        backgroundColor: Colors.black,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 10),
            _buildHeader(),
            const SizedBox(height: 20),
            _buildSearchField(),
            const SizedBox(height: 20),
            _buildCategoryRow(),
            const SizedBox(height: 25),
            _isLoading ? _buildLoadingGrid() : _buildItemsGrid(),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.videogame_asset, color: AppColors.primary, size: 28),
        SizedBox(width: 8),
        Text(
          AppStrings.appName,
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: AppColors.textPrimary, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: AppColors.textPrimary),
              onChanged: _searchItems,
              decoration: const InputDecoration(
                hintText: "Search for games or accessories...",
                hintStyle: TextStyle(color: AppColors.textHint, fontSize: 14),
                border: InputBorder.none,
              ),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(
                Icons.clear,
                color: AppColors.textHint,
                size: 20,
              ),
              onPressed: () {
                _searchController.clear();
                _searchItems('');
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryRow() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final isActive = _activeCategoryIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                _activeCategoryIndex = index;
                _searchController.clear();
              });
              _filterItems();
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
              child: Center(
                child: Text(
                  _categories[index],
                  style: TextStyle(
                    color: isActive
                        ? AppColors.textPrimary
                        : AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        childAspectRatio: 0.72,
      ),
      itemBuilder: (ctx, i) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
    );
  }

  Widget _buildItemsGrid() {
    if (_displayedItems.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              Icon(Icons.search_off, size: 64, color: Colors.grey[700]),
              const SizedBox(height: 16),
              Text(
                'No items found',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try a different search or category',
                style: TextStyle(color: Colors.grey[700], fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _displayedItems.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        childAspectRatio: 0.72,
      ),
      itemBuilder: (ctx, i) => _buildItemCard(_displayedItems[i]),
    );
  }

// Replace the _buildItemCard method in your home_screen.dart with this:

Widget _buildItemCard(ItemModel item) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => Productpage(item: item)),
      ).then((_) => _loadItems());
    },
    child: Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildItemImage(item),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title with ellipsis - FIXED
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Price
                  _buildPriceTag(item),
                  const Spacer(),
                  // Bottom row with badge and buttons - FIXED
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Type badge - flexible to shrink if needed
                      Flexible(
                        child: _buildTypeBadge(item.type ?? AppStrings.sell),
                      ),
                      const SizedBox(width: 8),
                      // Buttons row - fixed size
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildFavoriteButton(item.itemId!),
                          if (_isOwner(item)) ...[
                            const SizedBox(width: 8),
                            _buildEditButton(item),
                          ],
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  bool _isOwner(ItemModel item) {
    return _currentUserId != null && _currentUserId == item.userId;
  }

  Widget _buildEditButton(ItemModel item) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EditItemScreen(
              item: item,
              onItemUpdated: (updated) {
                final idx = _allItems.indexWhere(
                  (it) => it.itemId == updated.itemId,
                );
                if (idx != -1) {
                  setState(() {
                    _allItems[idx] = updated;
                    _filterItems();
                  });
                }
              },
            ),
          ),
        );

        // Always reload items from database after editing
        if (mounted) {
          await _loadItems();
          await _loadFavorites();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.edit, color: Colors.white, size: 18),
      ),
    );
  }

  Widget _buildItemImage(ItemModel item) {
    return Stack(
      children: [
        Container(
          height: 140,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            color: Colors.grey[800],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            child: Image.network(
              item.imageUrl ?? 'https://via.placeholder.com/300',
              fit: BoxFit.cover,
              width: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Icon(
                    Icons.broken_image,
                    size: 40,
                    color: Colors.grey[600],
                  ),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                        : null,
                    color: const Color(0xFF9C4DFF),
                  ),
                );
              },
            ),
          ),
        ),
        if (!item.status)
          Container(
            height: 140,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              color: Colors.black.withOpacity(0.7),
            ),
            child: const Center(
              child: Text(
                'UNAVAILABLE',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPriceTag(ItemModel item) {
    String priceText;
    if (item.type == 'rent') {
      priceText = '\$${item.price ?? 0}/day';
    } else if (item.type == 'trade') {
      priceText = 'Trade';
    } else {
      priceText = '\$${item.price ?? 0}';
    }

    return Text(
      priceText,
      style: const TextStyle(
        color: Color(0xFF9C4DFF),
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    );
  }

  Widget _buildTypeBadge(String type) {
    Color color;
    String label;
    if (type == AppStrings.rent) {
      color = AppColors.info;
      label = AppStrings.rent;
    } else if (type == AppStrings.trade) {
      color = AppColors.primaryLight;
      label = AppStrings.trade;
    } else {
      color = AppColors.success;
      label = AppStrings.sell;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildFavoriteButton(int itemId) {
    final isFavorited = _favoritedItemIds.contains(itemId);
    return GestureDetector(
      onTap: () => _toggleFavorite(itemId),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          isFavorited ? Icons.favorite : Icons.favorite_border,
          color: isFavorited ? Colors.red : Colors.white,
          size: 18,
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          // Refresh data when Home tab is tapped
          if (index == 0) {
            _loadItems();
            _loadFavorites();
          }
        },
        backgroundColor: Colors.transparent,
        selectedItemColor: const Color(0xFF9C4DFF),
        unselectedItemColor: Colors.grey,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Add',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
