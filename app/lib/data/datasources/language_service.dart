import 'package:shared_preferences/shared_preferences.dart';

class LanguageService {
  static const String _languageKey = 'selected_language';

  /// Save selected language code to local storage
  static Future<void> saveLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
  }

  /// Get saved language code from local storage
  /// Returns 'en' as default if no language is saved
  static Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey) ?? 'en';
  }

  /// Check if a language has been set
  static Future<bool> hasLanguageSet() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_languageKey);
  }

  /// Clear saved language (reset to default)
  static Future<void> clearLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_languageKey);
  }
}
