import 'package:flutter/material.dart';
import 'package:mobile_dev_app_gaming/l10n/app_localizations.dart';
import '../contact_seller_screen.dart';
import '../home/home_screen.dart';
import '../profile_screen.dart';
import '../item/add_listing_screen.dart';
import '../../../data/models/item_model.dart';
// ignore: unused_import
import '../../../core/widgets/custom_button.dart';
import '../../../core/constants/app_colors.dart';

class Productpage extends StatefulWidget {
  final ItemModel item;
  const Productpage({super.key, required this.item});

  @override
  State<Productpage> createState() => _ProductpageState();
}

class _ProductpageState extends State<Productpage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        ),
        title: Text(
          widget.item.title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Image Section - FIXED WIDTH, ADAPTIVE HEIGHT
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: double.infinity,
                        color: AppColors.cardBackground,
                        child:
                            widget.item.imageUrl != null &&
                                widget.item.imageUrl!.isNotEmpty
                            ? Image.network(
                                widget.item.imageUrl!,
                                fit: BoxFit.contain,
                                width: double.infinity,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 300,
                                    alignment: Alignment.center,
                                    child: const Icon(
                                      Icons.videogame_asset,
                                      color: AppColors.textSecondary,
                                      size: 48,
                                    ),
                                  );
                                },
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        height: 300,
                                        alignment: Alignment.center,
                                        child: CircularProgressIndicator(
                                          color: AppColors.primary,
                                          value:
                                              loadingProgress
                                                      .expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                              : null,
                                        ),
                                      );
                                    },
                              )
                            : Container(
                                height: 300,
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.videogame_asset,
                                  color: AppColors.textSecondary,
                                  size: 48,
                                ),
                              ),
                      ),
                    ),
                  ),

                  // Product Info Section - RIGHT AFTER IMAGE
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Title
                        Text(
                          widget.item.title,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Category
                        Text(
                          widget.item.category ?? l10n.uncategorized,
                          style: const TextStyle(
                            color: AppColors.textHint,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Price/Type
                        Text(
                          widget.item.type == 'trade'
                              ? l10n.trade
                              : widget.item.type == 'rent'
                              ? l10n.pricePerDay(
                                  (widget.item.price ?? 0).toInt(),
                                )
                              : 'DZD${widget.item.price ?? 0}',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Description
                        Text(
                          widget.item.description ?? l10n.noDescription,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            height: 1.5,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Add bottom padding to prevent content from being hidden behind fixed button
                  const SizedBox(height: 90),
                ],
              ),
            ),
          ),

          // Fixed Contact Seller Button at Bottom
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: AppColors.background,
              boxShadow: [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ContactSellerScreen(sellerId: widget.item.userId),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    l10n.contactSeller,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.textSecondary, width: 0.5),
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: AppColors.background,
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined),
              label: l10n.home,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.add_circle_outline),
              label: l10n.add,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outlined),
              label: l10n.profile,
            ),
          ],
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });

            if (index == 0) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            } else if (index == 1) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => AddListingScreen(
                    onItemCreated: (_) {},
                    redirectToHome: true,
                  ),
                ),
              );
            } else if (index == 2) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            }
          },
        ),
      ),
    );
  }
}
