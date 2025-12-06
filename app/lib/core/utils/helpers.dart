import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Helper utilities for the application
class Helpers {
  Helpers._(); // Private constructor to prevent instantiation

  /// Shows a snackbar with the given message
  static void showSnackbar(
    BuildContext context,
    String message, {
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: duration,
        action: action,
      ),
    );
  }

  /// Shows a success snackbar
  static void showSuccessSnackbar(BuildContext context, String message) {
    showSnackbar(context, message, backgroundColor: Colors.green);
  }

  /// Shows an error snackbar
  static void showErrorSnackbar(BuildContext context, String message) {
    showSnackbar(context, message, backgroundColor: Colors.red);
  }

  /// Shows an info snackbar
  static void showInfoSnackbar(BuildContext context, String message) {
    showSnackbar(context, message, backgroundColor: Colors.blue);
  }

  /// Validates phone number format
  static bool isValidPhoneNumber(String? phoneNumber) {
    if (phoneNumber == null || phoneNumber.isEmpty) return false;
    // Remove any non-digit characters except +
    final cleaned = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    // Must have at least 9 digits
    return cleaned.replaceAll('+', '').length >= 9;
  }

  /// Validates email format
  static bool isValidEmail(String? email) {
    if (email == null || email.isEmpty) return false;
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  /// Formats phone number for international use (adds country code if needed)
  static String formatPhoneForInternational(
    String phoneNumber, {
    String defaultCountryCode = '213',
  }) {
    // Remove all non-digit characters
    String cleaned = phoneNumber.replaceAll(RegExp(r'\D'), '');

    // If it starts with 0, remove it and add country code
    if (cleaned.startsWith('0')) {
      cleaned = defaultCountryCode + cleaned.substring(1);
    }
    // If it doesn't start with country code, add it
    else if (!cleaned.startsWith(defaultCountryCode) && cleaned.length <= 10) {
      cleaned = defaultCountryCode + cleaned;
    }

    return cleaned;
  }

  /// Opens a phone dialer with the given phone number
  static Future<void> makePhoneCall(String phoneNumber) async {
    if (!isValidPhoneNumber(phoneNumber)) {
      throw 'Invalid phone number';
    }

    // Format with + for tel: scheme
    final formattedNumber = '+${formatPhoneForInternational(phoneNumber)}';
    final Uri phoneUri = Uri(scheme: 'tel', path: formattedNumber);

    debugPrint('makePhoneCall: Attempting to launch $phoneUri');

    try {
      final launched = await launchUrl(phoneUri);
      if (!launched) {
        debugPrint('makePhoneCall: launchUrl returned false');
        throw 'Could not launch phone dialer';
      }
      debugPrint('makePhoneCall: Successfully launched');
    } catch (e) {
      debugPrint('makePhoneCall: Error - $e');
      throw 'Could not launch phone dialer';
    }
  }

  /// Opens WhatsApp with the given phone number
  static Future<void> openWhatsApp(
    String phoneNumber, [
    String? message,
  ]) async {
    if (!isValidPhoneNumber(phoneNumber)) {
      throw 'Invalid phone number';
    }

    // Format phone number for WhatsApp (international format without +)
    final cleanNumber = formatPhoneForInternational(phoneNumber);

    // Build WhatsApp URL using https://wa.me format
    final String whatsappUrl = message != null
        ? 'https://wa.me/$cleanNumber?text=${Uri.encodeComponent(message)}'
        : 'https://wa.me/$cleanNumber';

    final Uri whatsappUri = Uri.parse(whatsappUrl);

    debugPrint('openWhatsApp: Attempting to launch $whatsappUri');

    try {
      final launched = await launchUrl(
        whatsappUri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        debugPrint('openWhatsApp: launchUrl returned false');
        throw 'Could not launch WhatsApp';
      }
      debugPrint('openWhatsApp: Successfully launched');
    } catch (e) {
      debugPrint('openWhatsApp: Error - $e');
      throw 'Could not launch WhatsApp';
    }
  }

  /// Opens email client with the given email address
  static Future<void> sendEmail(
    String email, {
    String? subject,
    String? body,
  }) async {
    if (!isValidEmail(email)) {
      throw 'Invalid email address';
    }

    final Map<String, String> queryParams = {};
    if (subject != null) queryParams['subject'] = subject;
    if (body != null) queryParams['body'] = body;

    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: queryParams.isNotEmpty
          ? _encodeQueryParameters(queryParams)
          : null,
    );

    debugPrint('sendEmail: Attempting to launch $emailUri');

    try {
      final launched = await launchUrl(emailUri);
      if (!launched) {
        debugPrint('sendEmail: launchUrl returned false');
        throw 'Could not launch email client';
      }
      debugPrint('sendEmail: Successfully launched');
    } catch (e) {
      debugPrint('sendEmail: Error - $e');
      throw 'Could not launch email client';
    }
  }

  /// Opens a URL in the browser
  static Future<void> openUrl(String url) async {
    final Uri uri = Uri.parse(url);

    debugPrint('openUrl: Attempting to launch $uri');

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        debugPrint('openUrl: launchUrl returned false');
        throw 'Could not launch $url';
      }
      debugPrint('openUrl: Successfully launched');
    } catch (e) {
      debugPrint('openUrl: Error - $e');
      throw 'Could not launch $url';
    }
  }

  /// Formats a price to display with currency
  static String formatPrice(double price, {String currency = '\$'}) {
    return '$currency${price.toStringAsFixed(2)}';
  }

  /// Shows a confirmation dialog
  static Future<bool> showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    Color? confirmColor,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF212121),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: Text(message, style: const TextStyle(color: Colors.grey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(cancelText, style: const TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: confirmColor ?? Colors.red,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  /// Shows a loading dialog
  static void showLoadingDialog(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: AlertDialog(
          backgroundColor: const Color(0xFF212121),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9C4DFF)),
              ),
              if (message != null) ...[
                const SizedBox(height: 16),
                Text(message, style: const TextStyle(color: Colors.white)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Hides the loading dialog
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  /// Encodes query parameters for URLs
  static String? _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map(
          (e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
        )
        .join('&');
  }

  /// Dismisses keyboard
  static void dismissKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }
}
