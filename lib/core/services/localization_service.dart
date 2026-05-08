import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  LocalizationNotifier() : super(const LocalizationState(
    language: AppLanguage.en,
    locale: Locale('en', 'US'),
  ));
  
  Locale _getLocaleFromLanguage(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return const Locale('en', 'US');
      case AppLanguage.hi:
        return const Locale('hi', 'IN');
    }
  }
  
  Future<void> setLanguage(AppLanguage language) async {
    final locale = _getLocaleFromLanguage(language);
    state = LocalizationState(language: language, locale: locale);
    // TODO: Save to SharedPreferences
  }
}

// Providers
final localizationStateProvider = StateNotifierProvider<LocalizationNotifier, LocalizationState>((ref) {
  return LocalizationNotifier();
});

final localizationNotifierProvider = localizationStateProvider.notifier;

final currentLanguageProvider = Provider<AppLanguage>((ref) {
  return ref.watch(localizationStateProvider).language;
});

final currentLocaleProvider = Provider<Locale>((ref) {
  return ref.watch(localizationStateProvider).locale;
});

// Helper function for getting localized strings
String getLocalizedString(String key, AppLanguage language) {
  switch (key) {
    case 'appName':
      switch (language) {
        case AppLanguage.en:
          return 'CodeWithNarendra';
        case AppLanguage.hi:
          return 'कोडविथनरेंद्र';
      }
    case 'welcomeMessage':
      switch (language) {
        case AppLanguage.en:
          return 'Welcome to CodeWithNarendra';
        case AppLanguage.hi:
          return 'कोडविथनरेंद्र में आपका स्वागत है';
      }
    case 'signIn':
      switch (language) {
        case AppLanguage.en:
          return 'Sign In';
        case AppLanguage.hi:
          return 'साइन इन करें';
      }
    case 'signUp':
      switch (language) {
        case AppLanguage.en:
          return 'Sign Up';
        case AppLanguage.hi:
          return 'साइन अप करें';
      }
    case 'portfolio':
      switch (language) {
        case AppLanguage.en:
          return 'Portfolio';
        case AppLanguage.hi:
          return 'पोर्टफोलियो';
      }
    case 'admin':
      switch (language) {
        case AppLanguage.en:
          return 'Admin';
        case AppLanguage.hi:
          return 'एडमिन';
      }
    case 'profile':
      switch (language) {
        case AppLanguage.en:
          return 'Profile';
        case AppLanguage.hi:
          return 'प्रोफाइल';
      }
    case 'projects':
      switch (language) {
        case AppLanguage.en:
          return 'Projects';
        case AppLanguage.hi:
          return 'प्रोजेक्ट्स';
      }
    case 'skills':
      switch (language) {
        case AppLanguage.en:
          return 'Skills';
        case AppLanguage.hi:
          return 'कौशल';
      }
    case 'about':
      switch (language) {
        case AppLanguage.en:
          return 'About';
        case AppLanguage.hi:
          return 'बारे में';
      }
    case 'contact':
      switch (language) {
        case AppLanguage.en:
          return 'Contact';
        case AppLanguage.hi:
          return 'संपर्क करें';
      }
    case 'dashboard':
      switch (language) {
        case AppLanguage.en:
          return 'Dashboard';
        case AppLanguage.hi:
          return 'डैशबोर्ड';
      }
    // Service Management Keys
    case 'servicesManagement':
      switch (language) {
        case AppLanguage.en:
          return 'Services Management';
        case AppLanguage.hi:
          return 'सेवा प्रबंधन';
      }
    case 'servicesFound':
      switch (language) {
        case AppLanguage.en:
          return 'services found';
        case AppLanguage.hi:
          return 'सेवाएं पाई गईं';
      }
    case 'addService':
      switch (language) {
        case AppLanguage.en:
          return 'Add Service';
        case AppLanguage.hi:
          return 'सेवा जोड़ें';
      }
    case 'editService':
      switch (language) {
        case AppLanguage.en:
          return 'Edit Service';
        case AppLanguage.hi:
          return 'सेवा संपादित करें';
      }
    case 'deleteService':
      switch (language) {
        case AppLanguage.en:
          return 'Delete Service';
        case AppLanguage.hi:
          return 'सेवा हटाएं';
      }
    case 'deleteServiceConfirm':
      switch (language) {
        case AppLanguage.en:
          return 'Are you sure you want to delete';
        case AppLanguage.hi:
          return 'क्या आप वाकई इस सेवा को हटाना चाहते हैं';
      }
    case 'title':
      switch (language) {
        case AppLanguage.en:
          return 'Title';
        case AppLanguage.hi:
          return 'शीर्षक';
      }
    case 'description':
      switch (language) {
        case AppLanguage.en:
          return 'Description';
        case AppLanguage.hi:
          return 'विवरण';
      }
    case 'icon':
      switch (language) {
        case AppLanguage.en:
          return 'Icon';
        case AppLanguage.hi:
          return 'आइकन';
      }
    case 'iconName':
      switch (language) {
        case AppLanguage.en:
          return 'Icon Name';
        case AppLanguage.hi:
          return 'आइकन नाम';
      }
    case 'color':
      switch (language) {
        case AppLanguage.en:
          return 'Color';
        case AppLanguage.hi:
          return 'रंग';
      }
    case 'titleRequired':
      switch (language) {
        case AppLanguage.en:
          return 'Title is required';
        case AppLanguage.hi:
          return 'शीर्षक आवश्यक है';
      }
    case 'descriptionRequired':
      switch (language) {
        case AppLanguage.en:
          return 'Description is required';
        case AppLanguage.hi:
          return 'विवरण आवश्यक है';
      }
    case 'noServicesFound':
      switch (language) {
        case AppLanguage.en:
          return 'No services found';
        case AppLanguage.hi:
          return 'कोई सेवा नहीं मिली';
      }
    case 'serviceAdded':
      switch (language) {
        case AppLanguage.en:
          return 'Service added successfully';
        case AppLanguage.hi:
          return 'सेवा सफलतापूर्वक जोड़ी गई';
      }
    case 'serviceUpdated':
      switch (language) {
        case AppLanguage.en:
          return 'Service updated successfully';
        case AppLanguage.hi:
          return 'सेवा सफलतापूर्वक अपडेट की गई';
      }
    case 'serviceDeleted':
      switch (language) {
        case AppLanguage.en:
          return 'Service deleted successfully';
        case AppLanguage.hi:
          return 'सेवा सफलतापूर्वक हटाई गई';
      }
    case 'serviceAddFailed':
      switch (language) {
        case AppLanguage.en:
          return 'Failed to add service';
        case AppLanguage.hi:
          return 'सेवा जोड़ने में विफल';
      }
    case 'serviceUpdateFailed':
      switch (language) {
        case AppLanguage.en:
          return 'Failed to update service';
        case AppLanguage.hi:
          return 'सेवा अपडेट करने में विफल';
      }
    case 'serviceDeleteFailed':
      switch (language) {
        case AppLanguage.en:
          return 'Failed to delete service';
        case AppLanguage.hi:
          return 'सेवा हटाने में विफल';
      }
    case 'titleHint':
      switch (language) {
        case AppLanguage.en:
          return 'e.g., Mobile App Development';
        case AppLanguage.hi:
          return 'उदाहरण: मोबाइल ऐप विकास';
      }
    case 'descriptionHint':
      switch (language) {
        case AppLanguage.en:
          return 'Service description';
        case AppLanguage.hi:
          return 'सेवा का विवरण';
      }
    // Skills Management Keys
    case 'skillsManagement':
      switch (language) {
        case AppLanguage.en:
          return 'Skills Management';
        case AppLanguage.hi:
          return 'कौशल प्रबंधन';
      }
    case 'skillsFound':
      switch (language) {
        case AppLanguage.en:
          return 'skills found';
        case AppLanguage.hi:
          return 'कौशल पाए गए';
      }
    case 'addSkill':
      switch (language) {
        case AppLanguage.en:
          return 'Add Skill';
        case AppLanguage.hi:
          return 'कौशल जोड़ें';
      }
    case 'editSkill':
      switch (language) {
        case AppLanguage.en:
          return 'Edit Skill';
        case AppLanguage.hi:
          return 'कौशल संपादित करें';
      }
    case 'deleteSkill':
      switch (language) {
        case AppLanguage.en:
          return 'Delete Skill';
        case AppLanguage.hi:
          return 'कौशल हटाएं';
      }
    case 'deleteSkillConfirm':
      switch (language) {
        case AppLanguage.en:
          return 'Are you sure you want to delete';
        case AppLanguage.hi:
          return 'क्या आप वाकई इस कौशल को हटाना चाहते हैं';
      }
    case 'name':
      switch (language) {
        case AppLanguage.en:
          return 'Name';
        case AppLanguage.hi:
          return 'नाम';
      }
    case 'nameHint':
      switch (language) {
        case AppLanguage.en:
          return 'e.g., Flutter';
        case AppLanguage.hi:
          return 'उदाहरण: Flutter';
      }
    case 'nameRequired':
      switch (language) {
        case AppLanguage.en:
          return 'Name is required';
        case AppLanguage.hi:
          return 'नाम आवश्यक है';
      }
    case 'category':
      switch (language) {
        case AppLanguage.en:
          return 'Category';
        case AppLanguage.hi:
          return 'श्रेणी';
      }
    case 'categoryHint':
      switch (language) {
        case AppLanguage.en:
          return 'e.g., Mobile Development';
        case AppLanguage.hi:
          return 'उदाहरण: Mobile Development';
      }
    case 'categoryRequired':
      switch (language) {
        case AppLanguage.en:
          return 'Category is required';
        case AppLanguage.hi:
          return 'श्रेणी आवश्यक है';
      }
    case 'level':
      switch (language) {
        case AppLanguage.en:
          return 'Level';
        case AppLanguage.hi:
          return 'स्तर';
      }
    case 'selectLevel':
      switch (language) {
        case AppLanguage.en:
          return 'Select level';
        case AppLanguage.hi:
          return 'स्तर चुनें';
      }
    case 'levelRequired':
      switch (language) {
        case AppLanguage.en:
          return 'Level is required';
        case AppLanguage.hi:
          return 'स्तर आवश्यक है';
      }
    case 'experience':
      switch (language) {
        case AppLanguage.en:
          return 'Experience';
        case AppLanguage.hi:
          return 'अनुभव';
      }
    case 'years':
      switch (language) {
        case AppLanguage.en:
          return 'years';
        case AppLanguage.hi:
          return 'वर्ष';
      }
    case 'experienceYears':
      switch (language) {
        case AppLanguage.en:
          return 'Experience (in years)';
        case AppLanguage.hi:
          return 'अनुभव (वर्षों में)';
      }
    case 'experienceRequired':
      switch (language) {
        case AppLanguage.en:
          return 'Experience is required';
        case AppLanguage.hi:
          return 'अनुभव आवश्यक है';
      }
    case 'noSkillsFound':
      switch (language) {
        case AppLanguage.en:
          return 'No skills found';
        case AppLanguage.hi:
          return 'कोई कौशल नहीं मिला';
      }
    case 'skillAdded':
      switch (language) {
        case AppLanguage.en:
          return 'Skill added successfully';
        case AppLanguage.hi:
          return 'कौशल सफलतापूर्वक जोड़ा गया';
      }
    case 'skillUpdated':
      switch (language) {
        case AppLanguage.en:
          return 'Skill updated successfully';
        case AppLanguage.hi:
          return 'कौशल सफलतापूर्वक अपडेट किया गया';
      }
    case 'skillDeleted':
      switch (language) {
        case AppLanguage.en:
          return 'Skill deleted successfully';
        case AppLanguage.hi:
          return 'कौशल सफलतापूर्वक हटाया गया';
      }
    case 'skillAddFailed':
      switch (language) {
        case AppLanguage.en:
          return 'Failed to add skill';
        case AppLanguage.hi:
          return 'कौशल जोड़ने में विफल';
      }
    case 'skillUpdateFailed':
      switch (language) {
        case AppLanguage.en:
          return 'Failed to update skill';
        case AppLanguage.hi:
          return 'कौशल अपडेट करने में विफल';
      }
    case 'skillDeleteFailed':
      switch (language) {
        case AppLanguage.en:
          return 'Failed to delete skill';
        case AppLanguage.hi:
          return 'कौशल हटाने में विफल';
      }
    // Education Management Keys
    case 'educationAdded':
      switch (language) {
        case AppLanguage.en:
          return 'Education added successfully';
        case AppLanguage.hi:
          return 'शिक्षा सफलतापूर्वक जोड़ी गई';
      }
    case 'educationUpdated':
      switch (language) {
        case AppLanguage.en:
          return 'Education updated successfully';
        case AppLanguage.hi:
          return 'शिक्षा सफलतापूर्वक अपडेट की गई';
      }
    case 'educationDeleted':
      switch (language) {
        case AppLanguage.en:
          return 'Education deleted successfully';
        case AppLanguage.hi:
          return 'शिक्षा सफलतापूर्वक हटाई गई';
      }
    case 'educationAddFailed':
      switch (language) {
        case AppLanguage.en:
          return 'Failed to add education';
        case AppLanguage.hi:
          return 'शिक्षा जोड़ने में विफल';
      }
    case 'educationUpdateFailed':
      switch (language) {
        case AppLanguage.en:
          return 'Failed to update education';
        case AppLanguage.hi:
          return 'शिक्षा अपडेट करने में विफल';
      }
    case 'educationDeleteFailed':
      switch (language) {
        case AppLanguage.en:
          return 'Failed to delete education';
        case AppLanguage.hi:
          return 'शिक्षा हटाने में विफल';
      }
    // Project Management Keys
    case 'projectAdded':
      switch (language) {
        case AppLanguage.en:
          return 'Project added successfully';
        case AppLanguage.hi:
          return 'प्रोजेक्ट सफलतापूर्वक जोड़ा गया';
      }
    case 'projectUpdated':
      switch (language) {
        case AppLanguage.en:
          return 'Project updated successfully';
        case AppLanguage.hi:
          return 'प्रोजेक्ट सफलतापूर्वक अपडेट किया गया';
      }
    case 'projectDeleted':
      switch (language) {
        case AppLanguage.en:
          return 'Project deleted successfully';
        case AppLanguage.hi:
          return 'प्रोजेक्ट सफलतापूर्वक हटाया गया';
      }
    case 'projectAddFailed':
      switch (language) {
        case AppLanguage.en:
          return 'Failed to add project';
        case AppLanguage.hi:
          return 'प्रोजेक्ट जोड़ने में विफल';
      }
    case 'projectUpdateFailed':
      switch (language) {
        case AppLanguage.en:
          return 'Failed to update project';
        case AppLanguage.hi:
          return 'प्रोजेक्ट अपडेट करने में विफल';
      }
    case 'projectDeleteFailed':
      switch (language) {
        case AppLanguage.en:
          return 'Failed to delete project';
        case AppLanguage.hi:
          return 'प्रोजेक्ट हटाने में विफल';
      }
    // About/Contact Management Keys
    case 'aboutSaved':
      switch (language) {
        case AppLanguage.en:
          return 'About information saved successfully';
        case AppLanguage.hi:
          return 'जानकारी सफलतापूर्वक सहेजी गई';
      }
    case 'aboutSaveFailed':
      switch (language) {
        case AppLanguage.en:
          return 'Failed to save about information';
        case AppLanguage.hi:
          return 'जानकारी सहेजने में विफल';
      }
    case 'contactSaved':
      switch (language) {
        case AppLanguage.en:
          return 'Contact saved successfully';
        case AppLanguage.hi:
          return 'संपर्क सफलतापूर्वक सहेजा गया';
      }
    case 'contactSaveFailed':
      switch (language) {
        case AppLanguage.en:
          return 'Failed to save contact';
        case AppLanguage.hi:
          return 'संपर्क सहेजने में विफल';
      }
    default:
      return key;
  }
  return key;
}

/// Extension on BuildContext for easy access to localized strings
extension LocalizationContext on BuildContext {
  String get appName => getLocalizedString('appName', AppLanguage.en);
  String get admin => getLocalizedString('admin', AppLanguage.en);
  String get dashboard => getLocalizedString('dashboard', AppLanguage.en);
  String get portfolio => getLocalizedString('portfolio', AppLanguage.en);
  String get profile => getLocalizedString('profile', AppLanguage.en);
  String get projects => getLocalizedString('projects', AppLanguage.en);
  String get skills => getLocalizedString('skills', AppLanguage.en);
  String get about => getLocalizedString('about', AppLanguage.en);
  String get contact => getLocalizedString('contact', AppLanguage.en);
  String get welcomeMessage => getLocalizedString('welcomeMessage', AppLanguage.en);
  String get signIn => getLocalizedString('signIn', AppLanguage.en);
  String get signUp => getLocalizedString('signUp', AppLanguage.en);
}
