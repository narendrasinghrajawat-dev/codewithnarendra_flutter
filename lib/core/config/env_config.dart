/// Environment Configuration
/// Uses hardcoded values for development
/// For production deployment, update these values directly
class EnvConfig {
  /// Initialize environment configuration
  /// Call this in main.dart before runApp
  static Future<void> init() async {
    print('Environment configuration initialized');
    print('API Base URL: $apiBaseUrl');
    print('Environment: $env');
  }

  /// Environment type
  static String get env => 'development';

  /// API Base URL
  static String get apiBaseUrl => 'http://localhost:3000/api';

  /// API Timeout in milliseconds
  static int get apiTimeout => 30000;

  /// Enable logging
  static bool get enableLogging => true;

  /// Check if running in development
  static bool get isDevelopment => env == 'development';

  /// Check if running in test
  static bool get isTest => env == 'test';

  /// Check if running in production
  static bool get isProduction => env == 'production';
}
