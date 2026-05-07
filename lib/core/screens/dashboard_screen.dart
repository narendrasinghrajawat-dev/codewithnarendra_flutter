import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../config/app_theme_colors.dart';
import '../config/app_icons.dart';
import '../../features/about/presentation/pages/about_screen.dart';
import '../../features/skills/presentation/pages/skill_screen.dart';
import '../../features/education/presentation/pages/education_screen.dart';
import '../../features/projects/presentation/pages/project_screen.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';

/// Dashboard screen with common top bar and bottom navigation
/// Manages all module tabs in one place
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedIndex = 0;

  // List of tabs with their labels and icons
  final List<_TabItem> _tabs = const [
    _TabItem(
      icon: Icons.person,
      label: 'About',
      widget: AboutScreen(),
    ),
    _TabItem(
      icon: Icons.code,
      label: 'Skills',
      widget: SkillScreen(),
    ),
    _TabItem(
      icon: Icons.school,
      label: 'Education',
      widget: EducationScreen(),
    ),
    _TabItem(
      icon: Icons.work,
      label: 'Projects',
      widget: ProjectScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Common Top Bar
      appBar: AppBar(
        title: Row(
          children: [
            // Logo in app bar
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: AppIcons.logoSmall(),
            ),
            const Text(
              'CodeWithNarendra',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: AppThemeColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          // Logout button
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(),
          ),
        ],
      ),
      // Content area based on selected tab
      body: IndexedStack(
        index: _selectedIndex,
        children: _tabs.map((tab) => tab.widget).toList(),
      ),
      // Common Bottom Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppThemeColors.primary,
          unselectedItemColor: AppThemeColors.grey600,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 12,
          ),
          items: _tabs
              .map((tab) => BottomNavigationBarItem(
                    icon: Icon(tab.icon),
                    label: tab.label,
                  ))
              .toList(),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final authController = ref.read(authControllerProvider.notifier);
              await authController.logout();
              if (mounted) {
                context.go('/login');
              }
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper class for tab items
class _TabItem {
  final IconData icon;
  final String label;
  final Widget widget;

  const _TabItem({
    required this.icon,
    required this.label,
    required this.widget,
  });
}
