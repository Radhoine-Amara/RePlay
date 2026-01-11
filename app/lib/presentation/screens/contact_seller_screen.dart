import 'package:flutter/material.dart';
import 'package:mobile_dev_app_gaming/l10n/app_localizations.dart';
import 'item/add_listing_screen.dart';
import 'profile_screen.dart';
import 'home/home_screen.dart';
import '../../data/models/user_model.dart';
import '../../data/datasources/user_service.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/helpers.dart';
import '../../core/widgets/loading_widget.dart';

class ContactSellerScreen extends StatefulWidget {
  final int sellerId;

  const ContactSellerScreen({super.key, required this.sellerId});

  @override
  State<ContactSellerScreen> createState() => _ContactSellerScreenState();
}

class _ContactSellerScreenState extends State<ContactSellerScreen> {
  final UserService _userService = UserService();
  UserModel? _seller;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSellerInfo();
  }

  Future<void> _loadSellerInfo() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final seller = await _userService.getUserById(widget.sellerId);
      setState(() {
        _seller = seller;
        _isLoading = false;
        if (seller == null) {
          _errorMessage = l10n.errorLoadingData;
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = l10n.errorLoadingData;
      });
    }
  }

  Future<void> _handlePhoneCall() async {
    final l10n = AppLocalizations.of(context)!;
    final phoneNumber = _seller?.phoneNum?.toString();

    if (phoneNumber == null || phoneNumber.isEmpty) {
      Helpers.showErrorSnackbar(context, l10n.phoneNotAvailable);
      return;
    }

    if (!Helpers.isValidPhoneNumber(phoneNumber)) {
      Helpers.showErrorSnackbar(context, l10n.phoneNotAvailable);
      return;
    }

    try {
      await Helpers.makePhoneCall(phoneNumber);
    } catch (e) {
      if (mounted) {
        Helpers.showErrorSnackbar(context, l10n.couldNotOpenPhoneDialer);
      }
    }
  }

  Future<void> _handleEmail() async {
    final l10n = AppLocalizations.of(context)!;
    final email = _seller?.email;

    if (email == null || email.isEmpty) {
      Helpers.showErrorSnackbar(context, l10n.emailNotAvailable);
      return;
    }

    if (!Helpers.isValidEmail(email)) {
      Helpers.showErrorSnackbar(context, l10n.emailNotAvailable);
      return;
    }

    try {
      await Helpers.sendEmail(email, subject: l10n.inquiryFromRePlay);
    } catch (e) {
      if (mounted) {
        Helpers.showErrorSnackbar(context, l10n.couldNotOpenEmailClient);
      }
    }
  }

  Future<void> _handleWhatsApp() async {
    final l10n = AppLocalizations.of(context)!;
    final phoneNumber = _seller?.phoneNum?.toString();

    if (phoneNumber == null || phoneNumber.isEmpty) {
      Helpers.showErrorSnackbar(context, l10n.phoneNotAvailable);
      return;
    }

    if (!Helpers.isValidPhoneNumber(phoneNumber)) {
      Helpers.showErrorSnackbar(context, l10n.phoneNotAvailable);
      return;
    }

    try {
      await Helpers.openWhatsApp(phoneNumber, l10n.whatsAppMessage);
    } catch (e) {
      if (mounted) {
        Helpers.showErrorSnackbar(context, l10n.couldNotOpenWhatsApp);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          l10n.contactSeller,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: _isLoading
          ? LoadingWidget(message: l10n.loadingSellerInfo)
          : _errorMessage != null
          ? _buildErrorState()
          : _buildContent(),
      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.background,
        currentIndex: 0,
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
    );
  }

  Widget _buildErrorState() {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 64),
          const SizedBox(height: 16),
          Text(
            _errorMessage ?? l10n.sellerNotFound,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _isLoading = true;
                _errorMessage = null;
              });
              _loadSellerInfo();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text(
              l10n.retry,
              style: const TextStyle(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Seller Info Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                // Profile Picture
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.inputBackground,
                    image:
                        _seller?.imageUrl != null &&
                            _seller!.imageUrl!.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(_seller!.imageUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _seller?.imageUrl == null || _seller!.imageUrl!.isEmpty
                      ? const Icon(
                          Icons.person,
                          size: 40,
                          color: AppColors.textSecondary,
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                // Seller Name
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _seller?.userName ?? l10n.guest,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _seller?.email ?? '',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Contact Options Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.contactOptions,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),

                // Phone Number Option
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.inputBackground,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    leading: const Icon(
                      Icons.phone,
                      color: AppColors.textSecondary,
                    ),
                    title: Text(
                      l10n.phoneNumber,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      _seller?.phoneNum != null
                          ? '+${_seller!.phoneNum}'
                          : l10n.phoneNotAvailable,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    onTap: _handlePhoneCall,
                  ),
                ),
                const SizedBox(height: 12),

                // Email Address Option
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.inputBackground,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    leading: const Icon(
                      Icons.email,
                      color: AppColors.textSecondary,
                    ),
                    title: Text(
                      l10n.emailAddress,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      _seller?.email ?? l10n.emailNotAvailable,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    onTap: _handleEmail,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Message Seller Button (WhatsApp)
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _handleWhatsApp,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.message),
              label: Text(
                l10n.messageSeller,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
