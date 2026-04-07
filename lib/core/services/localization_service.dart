import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';

enum AppLanguage { en, hi }

class LocalizationState {
  final AppLanguage language;
  final Locale locale;
  
  const LocalizationState({
    required this.language,
    required this.locale,
  });
  
  LocalizationState copyWith({
    AppLanguage? language,
    Locale? locale,
  }) {
    return LocalizationState(
      language: language ?? this.language,
      locale: locale ?? this.locale,
    );
  }
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalizationState &&
          runtimeType == other.runtimeType &&
          language == other.language &&
          locale == other.locale;

  @override
  int get hashCode => Object.hash(language, locale);
}

class LocalizationNotifier extends StateNotifier<LocalizationState> {
  final SharedPreferences _prefs;
  
  LocalizationNotifier(this._prefs) : super(const LocalizationState(
    language: AppLanguage.en,
    locale: Locale('en', 'US'),
  )) {
    _loadLanguage();
  }
  
  Future<void> _loadLanguage() async {
    final savedLanguage = _prefs.getString(AppConstants.languageKey);
    final language = savedLanguage != null
        ? AppLanguage.values.firstWhere(
            (lang) => lang.name == savedLanguage,
            orElse: () => AppLanguage.en,
          )
        : AppLanguage.en;
    
    final locale = _getLocaleFromLanguage(language);
    state = LocalizationState(language: language, locale: locale);
  }
  
  Locale _getLocaleFromLanguage(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return const Locale('en', 'US');
      case AppLanguage.hi:
        return const Locale('hi', 'IN');
      default:
        return const Locale('en', 'US');
    }
  }
  
  Future<void> setLanguage(AppLanguage language) async {
    final locale = _getLocaleFromLanguage(language);
    state = LocalizationState(language: language, locale: locale);
    await _prefs.setString(AppConstants.languageKey, language.name);
  }
}

// Providers
final localizationNotifierProvider = StateNotifierProvider<LocalizationNotifier, LocalizationState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocalizationNotifier(prefs);
});

final localizationStateProvider = Provider<LocalizationState>((ref) {
  return ref.watch(localizationNotifierProvider);
});

final currentLanguageProvider = Provider<AppLanguage>((ref) {
  return ref.watch(localizationStateProvider).language;
});

final currentLocaleProvider = Provider<Locale>((ref) {
  return ref.watch(localizationStateProvider).locale;
});

// Extension for getting localized strings
extension AppLocalizationsExtension on BuildContext {
  String get appName {
    final language = read(currentLanguageProvider);
    switch (language) {
      case AppLanguage.en:
        return 'MyFolio';
      case AppLanguage.hi:
        return 'मेरा पोर्टफोलियो';
      default:
        return 'MyFolio';
    }
  }
  
  String get welcomeMessage {
    final language = read(currentLanguageProvider);
    switch (language) {
      case AppLanguage.en:
        return 'Welcome to MyFolio';
      case AppLanguage.hi:
        return 'मेरा पोर्टफोलियो में आपका स्वागत है';
      default:
        return 'Welcome to MyFolio';
    }
  }
  
  String get signIn {
    final language = read(currentLanguageProvider);
    switch (language) {
      case AppLanguage.en:
        return 'Sign In';
      case AppLanguage.hi:
        return 'साइन इन करें';
      default:
        return 'Sign In';
    }
  }
  
  String get signUp {
    final language = read(currentLanguageProvider);
    switch (language) {
      case AppLanguage.en:
        return 'Sign Up';
      case AppLanguage.hi:
        return 'साइन अप करें';
      default:
        return 'Sign Up';
    }
  }
  
  String get portfolio {
    final language = read(currentLanguageProvider);
    switch (language) {
      case AppLanguage.en:
        return 'Portfolio';
      case AppLanguage.hi:
        return 'पोर्टफोलियो';
      default:
        return 'Portfolio';
    }
  }
  
  String get admin {
    final language = read(currentLanguageProvider);
    switch (language) {
      case AppLanguage.en:
        return 'Admin';
      case AppLanguage.hi:
        return 'एडमिन';
      default:
        return 'Admin';
    }
  }
  
  String get profile {
    final language = read(currentLanguageProvider);
    switch (language) {
      case AppLanguage.en:
        return 'Profile';
      case AppLanguage.hi:
        return 'प्रोफाइल';
      default:
        return 'Profile';
    }
  }
  
  String get projects {
    final language = read(currentLanguageProvider);
    switch (language) {
      case AppLanguage.en:
        return 'Projects';
      case AppLanguage.hi:
        return 'प्रोजेक्ट्स';
      default:
        return 'Projects';
    }
  }
  
  String get skills {
    final language = read(currentLanguageProvider);
    switch (language) {
      case AppLanguage.en:
        return 'Skills';
      case AppLanguage.hi:
        return 'कौशल';
      default:
        return 'Skills';
    }
  }
  
  String get about {
    final language = read(currentLanguageProvider);
    switch (language) {
      case AppLanguage.en:
        return 'About';
      case AppLanguage.hi:
        return 'बारे में';
      default:
        return 'About';
    }
  }
  
  String get contact {
    final language = read(currentLanguageProvider);
    switch (language) {
      case AppLanguage.en:
        return 'Contact';
      case AppLanguage.hi:
        return 'संपर्क करें';
      default:
        return 'Contact';
    }
  }
  
  String get dashboard {
    final language = read(currentLanguageProvider);
    switch (language) {
      case AppLanguage.en:
        return 'Dashboard';
      case AppLanguage.hi:
        return 'डैशबोर्ड';
      default:
        return 'Dashboard';
    }
  }
}
