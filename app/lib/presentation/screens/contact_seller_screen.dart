import 'package:flutter/material.dart';
import 'item/add_listing_screen.dart';
import 'profile_screen.dart';
import 'home/home_screen.dart';
import '../../data/models/user_model.dart';
import '../../data/datasources/user_service.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
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
    try {
      final seller = await _userService.getUserById(widget.sellerId);
      setState(() {
        _seller = seller;
        _isLoading = false;
        if (seller == null) {
          _errorMessage = AppStrings.errorLoadingData;
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = AppStrings.errorLoadingData;
      });
    }
  }

  Future<void> _handlePhoneCall() async {
    final phoneNumber = _seller?.phoneNum?.toString();

    if (phoneNumber == null || phoneNumber.isEmpty) {
      Helpers.showErrorSnackbar(context, 'Phone number not available');
      return;
    }

    if (!Helpers.isValidPhoneNumber(phoneNumber)) {
      Helpers.showErrorSnackbar(context, 'Invalid phone number');
      return;
    }

    try {
      await Helpers.makePhoneCall(phoneNumber);
    } catch (e) {
      if (mounted) {
        Helpers.showErrorSnackbar(context, 'Could not open phone dialer');
      }
    }
  }

  Future<void> _handleEmail() async {
    final email = _seller?.email;

    if (email == null || email.isEmpty) {
      Helpers.showErrorSnackbar(context, 'Email not available');
      return;
    }

    if (!Helpers.isValidEmail(email)) {
      Helpers.showErrorSnackbar(context, 'Invalid email address');
      return;
    }

    try {
      await Helpers.sendEmail(email, subject: 'Inquiry from RePlay App');
    } catch (e) {
      if (mounted) {
        Helpers.showErrorSnackbar(context, 'Could not open email client');
      }
    }
  }

  Future<void> _handleWhatsApp() async {
    final phoneNumber = _seller?.phoneNum?.toString();

    if (phoneNumber == null || phoneNumber.isEmpty) {
      Helpers.showErrorSnackbar(
        context,
        'Phone number not available for WhatsApp',
      );
      return;
    }

    if (!Helpers.isValidPhoneNumber(phoneNumber)) {
      Helpers.showErrorSnackbar(context, 'Invalid phone number');
      return;
    }

    try {
      await Helpers.openWhatsApp(
        phoneNumber,
        'Hi! I found your listing on RePlay and I\'m interested.',
      );
    } catch (e) {
      if (mounted) {
        Helpers.showErrorSnackbar(context, 'Could not open WhatsApp');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          AppStrings.contactSeller,
          style: TextStyle(
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
          ? const LoadingWidget(message: 'Loading seller info...')
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
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: AppStrings.home,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: AppStrings.add,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outlined),
            label: AppStrings.profile,
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 64),
          const SizedBox(height: 16),
          Text(
            _errorMessage ?? AppStrings.sellerNotFound,
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
            child: const Text(
              AppStrings.tryAgain,
              style: TextStyle(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
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
                        _seller?.userName ?? AppStrings.guest,
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
                const Text(
                  AppStrings.contactOptions,
                  style: TextStyle(
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
                    title: const Text(
                      AppStrings.phoneNumber,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      _seller?.phoneNum != null
                          ? '+${_seller!.phoneNum}'
                          : AppStrings.phoneNotAvailable,
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
                    title: const Text(
                      AppStrings.emailAddress,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      _seller?.email ?? AppStrings.emailNotAvailable,
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
              label: const Text(
                AppStrings.messageSeller,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
