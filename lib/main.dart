import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';

import 'core/services/api_service.dart';
import 'core/themes/app_theme.dart';
import 'auth/auth_notifier.dart';
import 'auth/login_screen.dart';
import 'auth/register_screen.dart';
import 'projects/project_notifier.dart';
import 'projects/project_list_screen.dart';
import 'projects/add_project_screen.dart';
import 'skills/skill_notifier.dart';
import 'skills/skills_screen.dart';
import 'education/education_notifier.dart';
import 'education/education_screen.dart';
import 'about/about_notifier.dart';
import 'about/about_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
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
    final authState = ref.watch(authStateProvider);
    
    return MaterialApp.router(
      title: 'MyFolio',
      debugShowCheckedModeBanner: false,
      routerConfig: GoRouter(
        navigatorKey: navigatorKey,
        initialLocation: authState.status == AuthStatus.authenticated 
            ? '/portfolio' 
            : '/login',
        routes: [
          // Auth Routes
          GoRoute(
            path: '/login',
            builder: (context, state) => LoginScreen(),
          ),
          GoRoute(
            path: '/register',
            builder: (context, state) => RegisterScreen(),
          ),
          
          // Main App Routes
          GoRoute(
            path: '/portfolio',
            builder: (context, state) => const PortfolioScreen(),
          ),
          GoRoute(
            path: '/projects',
            builder: (context, state) => const ProjectListScreen(),
          ),
          GoRoute(
            path: '/add-project',
            builder: (context, state) => const AddProjectScreen(),
          ),
          GoRoute(
            path: '/skills',
            builder: (context, state) => const SkillsScreen(),
          ),
          GoRoute(
            path: '/education',
            builder: (context, state) => EducationScreen(),
          ),
          GoRoute(
            path: '/about',
            builder: (context, state) => AboutScreen(),
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
    final authState = ref.watch(authStateProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('MyFolio'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authNotifierProvider.notifier).signOut();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              'Welcome to MyFolio',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Hello ${authState.displayName ?? 'User'}!',
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
