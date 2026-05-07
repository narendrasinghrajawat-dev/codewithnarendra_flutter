import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

/// Environment Configuration
/// Auto-detects the correct backend URL based on the runtime platform:
///   - Web (Chrome)       → http://localhost:3000/api
///   - Android Emulator   → http://10.0.2.2:3000/api
///   - iOS Simulator      → http://localhost:3000/api
///   - Physical Device    → http://192.168.31.141:3000/api  (your PC's IP)
///
/// To change the IP address for physical devices:
/// Option 1: Set environment variable DEV_MACHINE_IP before running
///   Windows: $env:DEV_MACHINE_IP="192.168.1.100"; flutter run
///   Linux/Mac: DEV_MACHINE_IP=192.168.1.100 flutter run
/// Option 2: Update the _devMachineIp constant below
class EnvConfig {
  /// Your development machine's local network IP address.
  /// Run 'ipconfig' on Windows → IPv4 Address
  /// Can be overridden with DEV_MACHINE_IP environment variable
  static String get _devMachineIp =>
      const String.fromEnvironment('DEV_MACHINE_IP', defaultValue: '192.168.31.141');

  /// Backend port
  static const int _port = 3000;

  /// Initialize environment configuration
  static Future<void> init() async {
    print('Environment configuration initialized');
    print('API Base URL: $apiBaseUrl');
    print('Environment: $env');
    print('Platform: ${_platformName()}');
  }

  static String _platformName() {
    if (kIsWeb) return 'Web';
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isWindows) return 'Windows';
    return 'Unknown';
  }

  /// Environment type
  static String get env => 'development';

  /// API Base URL — automatically picks the right host per platform
  static String get apiBaseUrl {
    if (kIsWeb) {
      // Running in Chrome — backend and browser share localhost
      return 'http://localhost:$_port/api';
    }

    if (Platform.isAndroid) {
      // ─────────────────────────────────────────────────────────────
      // Option A: USB + adb reverse (set USE_ADB_REVERSE=true)
      //   Run once in terminal: adb reverse tcp:3000 tcp:3000
      //   Phone treats localhost:3000 as the PC's backend — works even
      //   when the router has AP-Isolation enabled.
      //
      // Option B: Same WiFi + LAN IP (set USE_ADB_REVERSE=false)
      //   Requires router AP-Isolation to be OFF.
      // ─────────────────────────────────────────────────────────────
      const bool useAdbReverse =
          bool.fromEnvironment('USE_ADB_REVERSE', defaultValue: false);

      if (useAdbReverse) {
        return 'http://localhost:$_port/api'; // tunnelled via adb reverse
      }
      return 'http://$_devMachineIp:$_port/api'; // LAN WiFi
    }

    if (Platform.isIOS) {
      // iOS simulator and physical device both reach host via LAN IP
      return 'http://$_devMachineIp:$_port/api';
    }

    // Desktop (Windows / macOS / Linux) — same machine, use localhost
    return 'http://localhost:$_port/api';
  }

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
