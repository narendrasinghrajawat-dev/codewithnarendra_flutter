import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment Configuration
/// Loads environment variables from .env file in root
/// To switch environments, copy the appropriate .env file to .env:
/// - For development: copy env/.env.dev to .env
/// - For test: copy env/.env.test to .env
/// - For production: copy env/.env.prod to .env
class EnvConfig {
  static bool _isInitialized = false;

  /// Initialize environment configuration
  /// Call this in main.dart before runApp
  static Future<void> init() async {
    if (_isInitialized) return;
    
    try {
      // Load from root directory
      await dotenv.load(fileName: '.env');
      _isInitialized = true;
      print('Environment loaded from .env');
      print('API Base URL: ${apiBaseUrl}');
      print('Environment: ${env}');
    } catch (e) {
      print('Error loading .env: $e');
      // Fallback to default values
      _isInitialized = true;
      print('Using default environment values');
    }
  }

  /// Get environment variable value
  static String get(String key, {String defaultValue = ''}) {
    if (!_isInitialized) {
      print('Warning: EnvConfig not initialized');
      return defaultValue;
    }
    return dotenv.get(key, fallback: defaultValue);
  }

  /// Environment type
  static String get env => get('ENV', defaultValue: 'development');

  /// API Base URL
  static String get apiBaseUrl => get('API_BASE_URL', defaultValue: 'http://localhost:3000/api');

  /// API Timeout in milliseconds
  static int get apiTimeout => int.tryParse(get('API_TIMEOUT', defaultValue: '30000')) ?? 30000;

  /// Enable logging
  static bool get enableLogging => get('ENABLE_LOGGING', defaultValue: 'true').toLowerCase() == 'true';

  /// Check if running in development
  static bool get isDevelopment => env == 'development';

  /// Check if running in test
  static bool get isTest => env == 'test';

  /// Check if running in production
  static bool get isProduction => env == 'production';
}
