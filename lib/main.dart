import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/app_constants.dart';
import 'core/services/theme_service.dart';
import 'core/services/localization_service.dart';
import 'core/themes/app_theme.dart';
import 'features/auth/presentation/auth_notifier.dart';
import 'features/auth/presentation/pages/splash_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/portfolio/presentation/pages/portfolio_page.dart';
import 'features/admin/presentation/pages/admin_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeStateProvider);
    final localizationState = ref.watch(localizationStateProvider);
    
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _getThemeMode(themeState.mode),
      locale: localizationState.locale,
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('hi', 'IN'),
      ],
      localizationsDelegates: const [
        // Add actual localization delegates here
      ],
      routerConfig: GoRouter(
        initialLocation: AppConstants.splashRoute,
        routes: [
          GoRoute(
            path: AppConstants.splashRoute,
            builder: (context, state) => const SplashPage(),
          ),
          GoRoute(
            path: AppConstants.loginRoute,
            builder: (context, state) => const LoginPage(),
          ),
          GoRoute(
            path: AppConstants.portfolioRoute,
            builder: (context, state) => const PortfolioPage(),
          ),
          GoRoute(
            path: AppConstants.adminRoute,
            builder: (context, state) => const AdminPage(),
          ),
        ],
      ),
    );
  }
  
  ThemeMode _getThemeMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return ThemeMode.light;
      case ThemeMode.dark:
        return ThemeMode.dark;
      case ThemeMode.system:
        return ThemeMode.system;
    }
  }
}

// Initialize SharedPreferences provider
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});
