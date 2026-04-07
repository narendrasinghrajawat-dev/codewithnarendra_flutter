class AppConstants {
  // API
  static const String apiBaseUrl = 'https://api.myfolio.com/api/v1';
  static const String apiTimeout = '30000';
  
  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userProfileKey = 'user_profile';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language_code';
  
  // App Info
  static const String appName = 'MyFolio';
  static const String appVersion = '1.0.0';
  
  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 32;
  static const int maxUsernameLength = 20;
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Cache
  static const int maxCacheSize = 100;
  static const Duration cacheExpiration = Duration(hours: 24);
  
  // Network
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 2);
  
  // Firebase
  static const String firebaseWebClientId = 'your-web-client-id';
  static const String firebaseIosClientId = 'your-ios-client-id';
  static const String firebaseAndroidClientId = 'your-android-client-id';
  
  // Routes
  static const String splashRoute = '/splash';
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String homeRoute = '/home';
  static const String portfolioRoute = '/portfolio';
  static const String adminRoute = '/admin';
  static const String profileRoute = '/profile';
  
  // Asset Paths
  static const String assetsImagesPath = 'assets/images/';
  static const String assetsIconsPath = 'assets/icons/';
  static const String assetsFontsPath = 'assets/fonts/';
  
  // Supported Languages
  static const List<String> supportedLanguages = ['en', 'hi'];
  static const String defaultLanguage = 'en';
}
