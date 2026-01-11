// FILE: lib/presentation/screens/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_dev_app_gaming/l10n/app_localizations.dart';
import '../../../data/models/item_model.dart';
import '../../../logic/item_cubit/item_cubit.dart';
import '../../../logic/item_cubit/item_state.dart';
import '../../../logic/favorite_cubit/favorite_cubit.dart';
import '../../../logic/favorite_cubit/favorite_state.dart';
import '../../../logic/auth_cubit/auth_cubit.dart';
import '../../../logic/auth_cubit/auth_state.dart';
import 'product_page_screen.dart';
import '../item/add_listing_screen.dart';
import '../profile_screen.dart';
import '../item/edit_item_screen.dart';
import '../../../core/constants/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  int _activeCategoryIndex = 0;

  final TextEditingController _searchController = TextEditingController();

  List<String> _getCategories(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      l10n.all,
      l10n.games,
      l10n.consoles,
      l10n.accessories,
      l10n.electronics,
    ];
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadData() {
    // Load items
    context.read<ItemCubit>().loadAllItems();

    // Load favorites if user is authenticated
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      context.read<FavoriteCubit>().loadFavorites(authState.user.userId!);
    }
  }

  void _onCategoryChanged(int index) {
    setState(() {
      _activeCategoryIndex = index;
      _searchController.clear();
    });

    if (index == 0) {
      context.read<ItemCubit>().filterByCategory('all');
    } else {
      // Use the English category names for filtering since that's what the backend uses
      final categoryKeys = [
        'All',
        'Games',
        'Consoles',
        'Accessories',
        'Electronics',
      ];
      context.read<ItemCubit>().filterByCategory(categoryKeys[index]);
    }
  }

  void _onSearchChanged(String query) {
    context.read<ItemCubit>().searchItems(query);
  }

  void _toggleFavorite(int itemId) {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      context.read<FavoriteCubit>().toggleFavorite(
        authState.user.userId!,
        itemId,
      );
    } else {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pleaseLoginToFavorite),
          backgroundColor: Colors.orange,
        ),
      );
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
            final l10n = AppLocalizations.of(context)!;
            // Refresh items from cubit
            context.read<ItemCubit>().refreshItems();
            // Switch back to home tab
            setState(() => _currentIndex = 0);
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.listingCreatedSuccess),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
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
        onRefresh: () async {
          context.read<ItemCubit>().refreshItems();
          final authState = context.read<AuthCubit>().state;
          if (authState is AuthAuthenticated) {
            context.read<FavoriteCubit>().loadFavorites(authState.user.userId!);
          }
        },
        color: const Color(0xFF9C4DFF),
        backgroundColor: Colors.black,
        child: BlocBuilder<ItemCubit, ItemState>(
          builder: (context, itemState) {
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const SizedBox(height: 10),
                _buildHeader(),
                const SizedBox(height: 20),
                _buildSearchField(),
                const SizedBox(height: 20),
                _buildCategoryRow(),
                const SizedBox(height: 25),
                _buildItemsContent(itemState),
                const SizedBox(height: 80),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildItemsContent(ItemState state) {
    if (state is ItemLoading) {
      return _buildLoadingGrid();
    } else if (state is ItemLoaded) {
      return _buildItemsGrid(state.filteredItems);
    } else if (state is ItemError) {
      return Center(
        child: Text(state.message, style: const TextStyle(color: Colors.red)),
      );
    }
    return _buildLoadingGrid();
  }

  Widget _buildHeader() {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.videogame_asset, color: AppColors.primary, size: 28),
        const SizedBox(width: 8),
        Text(
          l10n.appName,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    final l10n = AppLocalizations.of(context)!;
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
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: l10n.searchHint,
                hintStyle: const TextStyle(
                  color: AppColors.textHint,
                  fontSize: 14,
                ),
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
                _onSearchChanged('');
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryRow() {
    final categories = _getCategories(context);
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final isActive = _activeCategoryIndex == index;
          return GestureDetector(
            onTap: () => _onCategoryChanged(index),
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
                  categories[index],
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

  Widget _buildItemsGrid(List<ItemModel> items) {
    final l10n = AppLocalizations.of(context)!;
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              Icon(Icons.search_off, size: 64, color: Colors.grey[700]),
              const SizedBox(height: 16),
              Text(
                l10n.noItemsFound,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.tryDifferentSearch,
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
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        childAspectRatio: 0.72,
      ),
      itemBuilder: (ctx, i) => _buildItemCard(items[i]),
    );
  }

  Widget _buildItemCard(ItemModel item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => Productpage(item: item)),
        ).then((_) => context.read<ItemCubit>().refreshItems());
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate image height based on available space (about 55% of card)
          final imageHeight = constraints.maxHeight * 0.55;

          return Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image section with dynamic height
                SizedBox(
                  height: imageHeight,
                  child: _buildItemImageContent(item),
                ),
                // Content section takes remaining space
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Title
                        Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        // Price
                        _buildPriceTag(item),
                        // Bottom row with badge and buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: _buildTypeBadge(
                                context,
                                item.type ?? 'sell',
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildFavoriteButton(item.itemId!),
                                if (_isOwner(item)) ...[
                                  const SizedBox(width: 6),
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
          );
        },
      ),
    );
  }

  Widget _buildItemImageContent(ItemModel item) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          item.imageUrl ?? 'https://via.placeholder.com/300',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[800],
              child: Center(
                child: Icon(
                  Icons.broken_image,
                  size: 40,
                  color: Colors.grey[600],
                ),
              ),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: Colors.grey[800],
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                      : null,
                  color: const Color(0xFF9C4DFF),
                ),
              ),
            );
          },
        ),
        if (!item.status)
          Container(
            color: Colors.black.withOpacity(0.7),
            child: Center(
              child: Text(
                AppLocalizations.of(context)!.unavailable,
                style: const TextStyle(
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

  bool _isOwner(ItemModel item) {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      return authState.user.userId == item.userId;
    }
    return false;
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
                // Refresh items via cubit
                context.read<ItemCubit>().refreshItems();
              },
            ),
          ),
        );

        // Always reload items from database after editing
        if (mounted) {
          context.read<ItemCubit>().refreshItems();
          final authState = context.read<AuthCubit>().state;
          if (authState is AuthAuthenticated) {
            context.read<FavoriteCubit>().loadFavorites(authState.user.userId!);
          }
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

  Widget _buildPriceTag(ItemModel item) {
    final l10n = AppLocalizations.of(context)!;
    String priceText;
    if (item.type == 'rent') {
      priceText = l10n.pricePerDay(item.price ?? 0);
    } else if (item.type == 'trade') {
      priceText = l10n.trade;
    } else {
      priceText = '\$${item.price ?? 0}';
    }

    return Text(
      priceText,
      style: const TextStyle(
        color: Color(0xFF9C4DFF),
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    );
  }

  Widget _buildTypeBadge(BuildContext context, String type) {
    final l10n = AppLocalizations.of(context)!;
    Color color;
    String label;

    // Convert to lowercase for consistent comparison
    final typeLower = type.toLowerCase();

    if (typeLower == 'rent') {
      color = AppColors.info;
      label = l10n.rent;
    } else if (typeLower == 'trade') {
      color = AppColors.primaryLight;
      label = l10n.trade;
    } else {
      color = AppColors.success;
      label = l10n.sell;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildFavoriteButton(int itemId) {
    return BlocBuilder<FavoriteCubit, FavoriteState>(
      builder: (context, state) {
        final isFavorited =
            state is FavoriteLoaded && state.favoriteIds.contains(itemId);
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
      },
    );
  }

  Widget _buildBottomNavBar() {
    final l10n = AppLocalizations.of(context)!;
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
            _loadData();
          }
        },
        backgroundColor: Colors.transparent,
        selectedItemColor: const Color(0xFF9C4DFF),
        unselectedItemColor: Colors.grey,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: l10n.home,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.add_circle_outline),
            label: l10n.add,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: l10n.profile,
          ),
        ],
      ),
    );
  }
}
