// FILE: lib/presentation/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_dev_app_gaming/l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/item_model.dart';
import '../../logic/profile_cubit/profile_cubit.dart';
import '../../logic/profile_cubit/profile_state.dart';
import '../../logic/item_cubit/item_cubit.dart';
import '../../logic/favorite_cubit/favorite_cubit.dart';
import '../../logic/auth_cubit/auth_cubit.dart';
import '../../logic/auth_cubit/auth_state.dart';
import '../../logic/language_cubit/language_cubit.dart';
import '../../logic/language_cubit/language_state.dart';
import '../../data/models/user_model.dart';
import 'edit_profile_screen.dart';
import 'home/product_page_screen.dart';
import 'item/edit_item_screen.dart';
import 'auth/login_screen.dart';
import '../../core/constants/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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

  void _loadUserData() {
    context.read<ProfileCubit>().loadProfile();
  }

  void _showLogoutDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(l10n.logout, style: const TextStyle(color: Colors.white)),
        content: Text(
          l10n.logoutConfirmation,
          style: const TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.cancel,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.logout),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    try {
      context.read<AuthCubit>().logout();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error logging out: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _resendVerificationEmail() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      // Do nothing if already verified
      if (_isEmailVerified()) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.emailAlreadyVerified),
            backgroundColor: Colors.green,
          ),
        );
        return;
      }

      final authUser = context.read<AuthCubit>();
      final currentState = authUser.state;

      if (currentState is! AuthAuthenticated) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.mustBeLoggedIn),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final email = currentState.user.email;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.sendingVerificationEmail),
          backgroundColor: Colors.blue,
        ),
      );

      // Resend email verification using Supabase auth OTP
      await Supabase.instance.client.auth.resend(
        type: OtpType.signup,
        email: email,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.verificationEmailSentTo(email)),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.error}: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  bool _isEmailVerified() {
    final user = Supabase.instance.client.auth.currentUser;
    return user?.emailConfirmedAt != null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoading) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        if (state is ProfileError) {
          final l10n = AppLocalizations.of(context)!;
          return Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadUserData,
                        child: Text(l10n.retry),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _showLogoutDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.withOpacity(0.2),
                          foregroundColor: Colors.red,
                        ),
                        child: Text(l10n.logout),
                      ),
                      if (!_isEmailVerified()) ...[
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: _resendVerificationEmail,
                          child: Text(
                            l10n.resendVerificationEmail,
                            style: const TextStyle(
                              color: AppColors.primary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        final user = state is ProfileLoaded ? state.user : null;
        final myListings = state is ProfileLoaded
            ? state.myListings
            : <ItemModel>[];
        final myFavorites = state is ProfileLoaded
            ? state.myFavorites
            : <ItemModel>[];

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(user),
                _buildTabBar(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildMyListings(myListings),
                      _buildFavorites(myFavorites),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(UserModel? user) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 10),
          // Language Switcher at top right
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [_buildLanguageSwitcher()],
          ),
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
                child: user?.imageUrl != null
                    ? ClipOval(
                        child: Image.network(
                          user!.imageUrl!,
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
            user?.userName ?? l10n.guest,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          // Edit Profile and Logout Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EditProfileScreen(),
                    ),
                  );
                  // Reload data after editing
                  _loadUserData();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surfaceLight,
                  foregroundColor: AppColors.textPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text(
                  l10n.editProfile,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _showLogoutDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.withOpacity(0.2),
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text(
                  l10n.logout,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Resend Email Verification Button (only if not verified)
          if (!_isEmailVerified())
            TextButton(
              onPressed: _resendVerificationEmail,
              child: Text(
                l10n.resendVerificationEmail,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLanguageSwitcher() {
    return BlocBuilder<LanguageCubit, LanguageState>(
      builder: (context, state) {
        final languageCubit = context.read<LanguageCubit>();
        final isEnglish = languageCubit.isEnglish;

        return GestureDetector(
          onTap: () => languageCubit.toggleLanguage(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.language, color: AppColors.primary, size: 18),
                const SizedBox(width: 6),
                Text(
                  isEnglish ? 'EN' : 'FR',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.swap_horiz,
                  color: AppColors.textHint,
                  size: 16,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabBar() {
    final l10n = AppLocalizations.of(context)!;
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
        tabs: [
          Tab(text: l10n.myListings),
          Tab(text: l10n.favorites),
        ],
      ),
    );
  }

  Widget _buildMyListings(List<ItemModel> myListings) {
    final l10n = AppLocalizations.of(context)!;
    if (myListings.isEmpty) {
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
              l10n.noListings,
              style: TextStyle(
                color: AppColors.textHint,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.startAddingItems,
              style: TextStyle(color: AppColors.textHint, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _loadUserData();
      },
      color: const Color(0xFF9C4DFF),
      child: GridView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: myListings.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          childAspectRatio: 0.72,
        ),
        itemBuilder: (ctx, i) => _buildMyListingCard(myListings[i]),
      ),
    );
  }

  Widget _buildFavorites(List<ItemModel> myFavorites) {
    final l10n = AppLocalizations.of(context)!;
    if (myFavorites.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 80, color: AppColors.textHint),
            const SizedBox(height: 16),
            Text(
              l10n.noFavorites,
              style: TextStyle(
                color: AppColors.textHint,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.startFavoritingItems,
              style: TextStyle(color: AppColors.textHint, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _loadUserData();
      },
      color: const Color(0xFF9C4DFF),
      child: GridView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: myFavorites.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          childAspectRatio: 0.72,
        ),
        itemBuilder: (ctx, i) => _buildFavoriteItemCard(myFavorites[i]),
      ),
    );
  }

  void _toggleFavorite(int itemId) {
    final l10n = AppLocalizations.of(context)!;
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      context.read<FavoriteCubit>().toggleFavorite(
        authState.user.userId!,
        itemId,
      );
      // Reload profile to update favorites list
      _loadUserData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.removedFromFavorites),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Widget _buildMyListingCard(ItemModel item) {
    return GestureDetector(
      onTap: () => _showListingOptions(item),
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
                SizedBox(
                  height: imageHeight,
                  child: _buildItemImageContent(item),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
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
                        _buildPriceTag(item),
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
          );
        },
      ),
    );
  }

  void _showListingOptions(ItemModel item) {
    final l10n = AppLocalizations.of(context)!;
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
                title: Text(
                  l10n.viewDetails,
                  style: const TextStyle(color: Colors.white),
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
                title: Text(
                  l10n.editListing,
                  style: const TextStyle(color: Colors.white),
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
                title: Text(
                  l10n.deleteListing,
                  style: const TextStyle(color: Colors.red),
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
            // Reload profile to get updated data
            _loadUserData();
          },
        ),
      ),
    );

    // Always reload from database to ensure we have fresh data
    if (mounted) {
      _loadUserData();
    }
  }

  Future<void> _confirmDeleteListing(ItemModel item) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          l10n.deleteListing,
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          l10n.deleteListingConfirmation(item.title),
          style: const TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              l10n.cancel,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true && item.itemId != null) {
      try {
        final success = await context.read<ItemCubit>().deleteItem(
          item.itemId!,
        );
        if (success) {
          // Reload profile data
          _loadUserData();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.listingDeletedSuccess),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.failedToDeleteListing),
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
                SizedBox(
                  height: imageHeight,
                  child: _buildItemImageContent(item),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
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
                        _buildPriceTag(item),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: _buildTypeBadge(
                                context,
                                item.type ?? 'sell',
                              ),
                            ),
                            _buildUnfavoriteButton(item.itemId!),
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

  /// Builds the image content for item cards (used inside SizedBox with dynamic height)
  Widget _buildItemImageContent(ItemModel item) {
    return Stack(
      children: [
        // Image container
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              color: Colors.grey[800],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              child: Image.network(
                item.imageUrl ?? 'https://via.placeholder.com/300',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
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
        ),
        // Unavailable overlay
        if (!item.status)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
                color: Colors.black.withOpacity(0.7),
              ),
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
          ),
      ],
    );
  }

  Widget _buildPriceTag(ItemModel item) {
    final l10n = AppLocalizations.of(context)!;
    String priceText;
    final type = item.type?.toLowerCase() ?? 'sell';

    if (type == 'rent') {
      priceText = l10n.pricePerDay(item.price ?? 0);
    } else if (type == 'trade') {
      priceText = l10n.trade;
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
