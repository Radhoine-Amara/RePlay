import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_dev_app_gaming/data/datasources/language_service.dart';
import 'package:mobile_dev_app_gaming/logic/language_cubit/language_state.dart';

class LanguageCubit extends Cubit<LanguageState> {
  static const Locale defaultLocale = Locale('en');
  static const List<Locale> supportedLocales = [Locale('en'), Locale('fr')];

  LanguageCubit() : super(LanguageInitial());

  /// Load the saved language preference or use default
  Future<void> loadLanguage() async {
    final savedLanguageCode = await LanguageService.getLanguage();
    final locale = Locale(savedLanguageCode);

    if (supportedLocales.contains(locale)) {
      emit(LanguageLoaded(locale));
    } else {
      emit(LanguageLoaded(defaultLocale));
    }
  }

  /// Change the app language
  Future<void> changeLanguage(Locale locale) async {
    if (!supportedLocales.contains(locale)) {
      return;
    }

    await LanguageService.saveLanguage(locale.languageCode);
    emit(LanguageLoaded(locale));
  }

  /// Get the current locale
  Locale get currentLocale {
    final state = this.state;
    if (state is LanguageLoaded) {
      return state.locale;
    }
    return defaultLocale;
  }

  /// Check if current language is English
  bool get isEnglish => currentLocale.languageCode == 'en';

  /// Check if current language is French
  bool get isFrench => currentLocale.languageCode == 'fr';

  /// Toggle between English and French
  Future<void> toggleLanguage() async {
    if (isEnglish) {
      await changeLanguage(const Locale('fr'));
    } else {
      await changeLanguage(const Locale('en'));
    }
  }
}
