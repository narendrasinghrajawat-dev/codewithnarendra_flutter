import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/app_theme_colors.dart';
import '../../../../core/services/localization_service.dart';
import '../../../../core/services/theme_service.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../widgets/admin_shell.dart';
import 'admin_dashboard_page.dart';
import 'skills_management_page.dart';
import 'projects_management_page.dart';
import 'education_management_page.dart';
import 'services_management_page.dart';
import 'about_management_page.dart';

/// Navigation items for admin panel
final List<AdminNavItem> adminNavItems = [
  const AdminNavItem(
    id: 'dashboard',
    labelEn: 'Dashboard',
    labelHi: 'डैशबोर्ड',
    icon: Icons.dashboard_outlined,
    selectedIcon: Icons.dashboard,
    color: Colors.blue,
  ),
  const AdminNavItem(
    id: 'skills',
    labelEn: 'Skills',
    labelHi: 'कौशल',
    icon: Icons.psychology_outlined,
    selectedIcon: Icons.psychology,
    color: Colors.indigo,
  ),
  const AdminNavItem(
    id: 'projects',
    labelEn: 'Projects',
    labelHi: 'परियोजनाएं',
    icon: Icons.folder_open_outlined,
    selectedIcon: Icons.folder_open,
    color: Colors.green,
  ),
  const AdminNavItem(
    id: 'education',
    labelEn: 'Education',
    labelHi: 'शिक्षा',
    icon: Icons.school_outlined,
    selectedIcon: Icons.school,
    color: Colors.orange,
  ),
  const AdminNavItem(
    id: 'services',
    labelEn: 'Services',
    labelHi: 'सेवाएं',
    icon: Icons.design_services_outlined,
    selectedIcon: Icons.design_services,
    color: Colors.purple,
  ),
  const AdminNavItem(
    id: 'about',
    labelEn: 'About',
    labelHi: 'बारे में',
    icon: Icons.person_outline,
    selectedIcon: Icons.person,
    color: Colors.teal,
  ),
];

/// Provider for current admin tab index
final adminTabIndexProvider = StateProvider<int>((ref) => 0);


/// Advanced Admin Page with responsive sidebar and tab navigation
class AdminPage extends ConsumerWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(adminTabIndexProvider);

    // Get current page title
    final currentItem = adminNavItems[currentIndex];
    final localizations = ref.watch(localizationStateProvider);
    final isHindi = localizations.language == AppLanguage.hi;
    final title = isHindi ? currentItem.labelHi : currentItem.labelEn;

    // Get current page content
    final pages = [
      const AdminDashboardPage(),
      const SkillsManagementPage(),
      const ProjectsManagementPage(),
      const EducationManagementPage(),
      const ServicesManagementPage(),
      const AboutManagementPage(),
    ];

    return AdminShell(
      body: pages[currentIndex],
      currentIndex: currentIndex,
      onDestinationSelected: (index) {
        ref.read(adminTabIndexProvider.notifier).state = index;
      },
      navItems: adminNavItems,
      title: title,
    );
  }
}
