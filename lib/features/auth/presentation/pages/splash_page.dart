import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/services/localization_service.dart';
import '../../../core/services/theme_service.dart';
import '../auth_notifier.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  SplashPageState createState() => SplashPageState();
}

class SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Initialize theme and language
    await Future.delayed(const Duration(seconds: 2));
    
    // Check authentication state
    final authNotifier = ref.read(authNotifierProvider);
    await authNotifier.checkAuthState();
    
    // Navigate to appropriate page after initialization
    if (mounted) {
      final isAuthenticated = ref.read(isAuthenticatedProvider);
      final context = this.context;
      
      if (isAuthenticated) {
        Navigator.of(context).pushReplacementNamed('/portfolio');
      } else {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeStateProvider);
    
    return Scaffold(
      backgroundColor: themeState.isDarkMode 
          ? AppTheme.darkBackgroundColor 
          : AppTheme.lightBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo/Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
              ),
              child: const Icon(
                Icons.work,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: AppTheme.spacingLarge),
            Text(
              context.appName,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMedium),
            const CircularProgressIndicator(),
            const SizedBox(height: AppTheme.spacingSmall),
            Text(
              context.welcomeMessage,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
