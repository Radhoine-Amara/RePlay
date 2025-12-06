// FILE: lib/presentation/screens/profile_screen.dart

import 'package:flutter/material.dart';
import '../../data/models/item_model.dart';
import '../../data/datasources/item_service.dart';
import '../../data/datasources/auth_service.dart';
import '../../data/datasources/user_service.dart';
import '../../data/datasources/favorite_service.dart';
import '../../data/models/user_model.dart';
import 'edit_profile_screen.dart';
import 'home/product_page_screen.dart';
import 'item/edit_item_screen.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final ItemService _itemService = ItemService();
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  final FavoriteService _favoriteService = FavoriteService();

  late TabController _tabController;
  UserModel? _currentUser;
  List<ItemModel> _myListings = [];
  List<ItemModel> _myFavorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    try {
      final authUser = _authService.getCurrentUser();
      print('Auth user: ${authUser?.email}'); // Debug

      if (authUser != null && authUser.email != null) {
        // Get database user
        final dbUser = await _userService.getUserByEmail(authUser.email!);
        print('DB user: ${dbUser?.userId}, ${dbUser?.userName}'); // Debug

        if (dbUser != null && dbUser.userId != null) {
          setState(() => _currentUser = dbUser);

          // Load user's listings
          final myItems = await _itemService.getItemsByUser(dbUser.userId!);
          print('My items count: ${myItems.length}'); // Debug

          // Load user's favorites
          final favorites = await _favoriteService.getUserFavorites(
            dbUser.userId!,
          );
          print('Favorites count: ${favorites.length}'); // Debug

          setState(() {
            _myListings = myItems;
            _myFavorites = favorites;
          });
        } else {
          print('DB user not found for email: ${authUser.email}');
        }
      } else {
        print('No authenticated user found');
      }
    } catch (e) {
      print('Error loading profile data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildMyListings(), _buildFavorites()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 10),
          // Profile Picture
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                  border: Border.all(color: AppColors.primary, width: 3),
                ),
                child: _currentUser?.imageUrl != null
                    ? ClipOval(
                        child: Image.network(
                          _currentUser!.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.person,
                              size: 60,
                              color: AppColors.textPrimary,
                            );
                          },
                        ),
                      )
                    : const Icon(
                        Icons.person,
                        size: 60,
                        color: AppColors.textPrimary,
                      ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.online,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.background, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Username
          Text(
            _currentUser?.userName ?? AppStrings.guest,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          // Edit Profile Button
          ElevatedButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
              // Reload data after editing
              _loadUserData();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.surfaceLight,
              foregroundColor: AppColors.textPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Text(
              AppStrings.editProfile,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(25),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(25),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: AppColors.textPrimary,
        unselectedLabelColor: AppColors.textHint,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        tabs: const [
          Tab(text: AppStrings.myListings),
          Tab(text: AppStrings.favorites),
        ],
      ),
    );
  }

  Widget _buildMyListings() {
    if (_myListings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 80,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.noListings,
              style: TextStyle(
                color: AppColors.textHint,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.startAddingItems,
              style: TextStyle(color: AppColors.textHint, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadUserData,
      color: const Color(0xFF9C4DFF),
      child: GridView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _myListings.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          childAspectRatio: 0.72,
        ),
        itemBuilder: (ctx, i) => _buildMyListingCard(_myListings[i]),
      ),
    );
  }

  Widget _buildFavorites() {
    if (_myFavorites.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 80, color: AppColors.textHint),
            const SizedBox(height: 16),
            Text(
              AppStrings.noFavorites,
              style: TextStyle(
                color: AppColors.textHint,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.startFavoritingItems,
              style: TextStyle(color: AppColors.textHint, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadUserData,
      color: const Color(0xFF9C4DFF),
      child: GridView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _myFavorites.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          childAspectRatio: 0.72,
        ),
        itemBuilder: (ctx, i) => _buildFavoriteItemCard(_myFavorites[i]),
      ),
    );
  }

  Future<void> _toggleFavorite(int itemId) async {
    if (_currentUser?.userId == null) return;

    try {
      await _favoriteService.toggleFavorite(_currentUser!.userId!, itemId);
      // Reload favorites after toggling
      await _loadUserData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Removed from favorites'),
            duration: Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print('Error toggling favorite: $e');
    }
  }

  Widget _buildMyListingCard(ItemModel item) {
    return GestureDetector(
      onTap: () => _showListingOptions(item),
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
                  children: [
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildPriceTag(item),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildTypeBadge(item.type ?? AppStrings.sell),
                        Row(
                          children: [
                            _buildEditButton(item),
                            const SizedBox(width: 4),
                            _buildDeleteButton(item),
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

  void _showListingOptions(ItemModel item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 20),
              // View Details
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.visibility, color: AppColors.primary),
                ),
                title: const Text(
                  'View Details',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => Productpage(item: item)),
                  ).then((_) => _loadUserData());
                },
              ),
              // Edit Listing
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit, color: Colors.blue),
                ),
                title: const Text(
                  'Edit Listing',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _editListing(item);
                },
              ),
              // Delete Listing
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.delete, color: Colors.red),
                ),
                title: const Text(
                  'Delete Listing',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _confirmDeleteListing(item);
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  void _editListing(ItemModel item) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditItemScreen(
          item: item,
          onItemUpdated: (updatedItem) {
            // This callback updates local state immediately
            final index = _myListings.indexWhere(
              (i) => i.itemId == updatedItem.itemId,
            );
            if (index != -1) {
              setState(() {
                _myListings[index] = updatedItem;
              });
            }
          },
        ),
      ),
    );

    // Always reload from database to ensure we have fresh data
    if (mounted) {
      await _loadUserData();
    }
  }

  Future<void> _confirmDeleteListing(ItemModel item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Delete Listing',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete "${item.title}"? This action cannot be undone.',
          style: const TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && item.itemId != null) {
      try {
        final success = await _itemService.deleteItem(item.itemId!);
        if (success) {
          setState(() {
            _myListings.removeWhere((i) => i.itemId == item.itemId);
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Listing deleted successfully'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to delete listing'),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      } catch (e) {
        print('Error deleting listing: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  Widget _buildEditButton(ItemModel item) {
    return GestureDetector(
      onTap: () => _editListing(item),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.edit, color: Colors.blue, size: 16),
      ),
    );
  }

  Widget _buildDeleteButton(ItemModel item) {
    return GestureDetector(
      onTap: () => _confirmDeleteListing(item),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.delete, color: Colors.red, size: 16),
      ),
    );
  }

  Widget _buildFavoriteItemCard(ItemModel item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => Productpage(item: item)),
        ).then((_) => _loadUserData());
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
                  children: [
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildPriceTag(item),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildTypeBadge(item.type ?? AppStrings.sell),
                        _buildUnfavoriteButton(item.itemId!),
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

  Widget _buildUnfavoriteButton(int itemId) {
    return GestureDetector(
      onTap: () => _toggleFavorite(itemId),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.favorite, color: Colors.red, size: 18),
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
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPriceTag(ItemModel item) {
  String priceText;
  final type = item.type?.toLowerCase() ?? 'sell';
  
  if (type == 'rent') {
    priceText = '\$${item.price ?? 0}/day'; // or ${AppStrings.rent.toLowerCase()}
  } else if (type == 'trade') {
    priceText = AppStrings.trade;
  } else {
    priceText = '\$${item.price ?? 0}';
  }
  return Text(
    priceText,
    style: const TextStyle(
      color: AppColors.primary,
      fontWeight: FontWeight.bold,
      fontSize: 16,
    ),
  );
}

  Widget _buildTypeBadge(String type) {
  Color color;
  String label;
  
  // Convert to lowercase for consistent comparison
  final typeLower = type.toLowerCase();
  
  if (typeLower == 'rent') {
    color = AppColors.info;
    label = AppStrings.rent; // This displays as "Rent"
  } else if (typeLower == 'trade') {
    color = AppColors.primaryLight;
    label = AppStrings.trade; // This displays as "Trade"
  } else {
    color = AppColors.success;
    label = AppStrings.sell; // This displays as "Sell"
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
}
