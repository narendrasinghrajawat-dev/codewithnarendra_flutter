import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'core/theme/app_theme.dart';
import 'core/providers/language_provider.dart';
import 'core/config/env_config.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';
import 'features/auth/presentation/pages/login_screen.dart';
import 'features/admin/presentation/pages/admin_login_screen.dart';
import 'features/admin/presentation/pages/admin_dashboard_screen.dart';
import 'features/projects/presentation/pages/project_screen.dart';
import 'features/skills/presentation/pages/skill_screen.dart';
import 'features/education/presentation/pages/education_screen.dart';
import 'features/about/presentation/pages/about_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize environment configuration
  await EnvConfig.init();
  
  // Initialize Firebase (optional - app works without it for JWT auth)
  try {
    await Firebase.initializeApp();
    debugPrint('Firebase initialized successfully');
  } catch (e) {
    // Firebase initialization failed - app will work without it for JWT auth
    debugPrint('Firebase initialization failed (app will continue without Firebase): $e');
  }
  
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(languageProvider);
    
    return MaterialApp.router(
      title: 'CodeWithNarendra',
      debugShowCheckedModeBanner: false,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: GoRouter(
        navigatorKey: navigatorKey,
        initialLocation: '/login',
        routes: [
          // User Auth Routes
          GoRoute(
            path: '/login',
            builder: (context, state) => const LoginScreen(),
          ),
          
          // Admin Auth Routes
          GoRoute(
            path: '/admin/login',
            builder: (context, state) => const AdminLoginScreen(),
          ),
          GoRoute(
            path: '/admin/dashboard',
            builder: (context, state) => const AdminDashboardScreen(),
          ),
          
          // Main App Routes
          GoRoute(
            path: '/portfolio',
            builder: (context, state) => const PortfolioScreen(),
          ),
          GoRoute(
            path: '/projects',
            builder: (context, state) => const ProjectScreen(),
          ),
          GoRoute(
            path: '/skills',
            builder: (context, state) => const SkillScreen(),
          ),
          GoRoute(
            path: '/education',
            builder: (context, state) => const EducationScreen(),
          ),
          GoRoute(
            path: '/about',
            builder: (context, state) => const AboutScreen(),
          ),
        ],
      ),
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
    );
  }
}

class PortfolioScreen extends ConsumerWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('CodeWithNarendra'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authControllerProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              'Welcome to CodeWithNarendra',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Hello ${authState.user?.email ?? 'User'}!',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 32),
            
            // Quick Actions Grid
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildQuickAction(
                  icon: Icons.work,
                  title: 'Projects',
                  onTap: () => context.push('/projects'),
                ),
                _buildQuickAction(
                  icon: Icons.school,
                  title: 'Skills',
                  onTap: () => context.push('/skills'),
                ),
                _buildQuickAction(
                  icon: Icons.history_edu,
                  title: 'Education',
                  onTap: () => context.push('/education'),
                ),
                _buildQuickAction(
                  icon: Icons.info,
                  title: 'About',
                  onTap: () => context.push('/about'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: Colors.blue,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
