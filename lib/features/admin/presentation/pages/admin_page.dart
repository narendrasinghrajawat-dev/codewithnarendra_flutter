import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/themes/app_theme.dart';
import '../../../core/services/localization_service.dart';
import '../../../core/services/theme_service.dart';
import '../auth_notifier.dart';

class AdminPage extends ConsumerWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeStateProvider);
    final authState = ref.watch(authStateProvider);
    
    // Check if user is admin
    if (!authState.user?.isUserAdmin ?? false) {
      return Scaffold(
        appBar: AppBar(
          title: Text(context.admin),
          backgroundColor: themeState.isDarkMode 
              ? AppTheme.darkSurfaceColor 
              : AppTheme.lightSurfaceColor,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.admin_panel_settings,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Access Denied',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You need admin privileges to access this page.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(context.dashboard),
        backgroundColor: themeState.isDarkMode 
            ? AppTheme.darkSurfaceColor 
            : AppTheme.lightSurfaceColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () {
              ref.read(themeNotifierProvider.notifier).toggleTheme();
            },
          ),
          PopupMenuButton<String>(
            onSelected: (language) {
              final lang = language == 'hi' ? AppLanguage.hi : AppLanguage.en;
              ref.read(localizationNotifierProvider.notifier).setLanguage(lang);
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'en',
                child: Text('English'),
              ),
              PopupMenuItem(
                value: 'hi',
                child: Text('हिंदी'),
              ),
            ],
          ),
        ],
      ),
      backgroundColor: themeState.isDarkMode 
          ? AppTheme.darkBackgroundColor 
          : AppTheme.lightBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Admin Stats Cards
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Total Projects',
                    '0',
                    Icons.work,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingMedium),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Total Users',
                    '0',
                    Icons.people,
                    Colors.green,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppTheme.spacingLarge),
            
            // Quick Actions
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppTheme.spacingMedium),
            
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: AppTheme.spacingMedium,
              mainAxisSpacing: AppTheme.spacingMedium,
              childAspectRatio: 1.5,
              children: [
                _buildActionCard(
                  context,
                  'Add Project',
                  Icons.add_circle,
                  Colors.blue,
                  () {
                    // Navigate to add project
                  },
                ),
                _buildActionCard(
                  context,
                  'Manage Projects',
                  Icons.list,
                  Colors.orange,
                  () {
                    // Navigate to manage projects
                  },
                ),
                _buildActionCard(
                  context,
                  'Manage Users',
                  Icons.people,
                  Colors.green,
                  () {
                    // Navigate to manage users
                  },
                ),
                _buildActionCard(
                  context,
                  'Settings',
                  Icons.settings,
                  Colors.grey,
                  () {
                    // Navigate to settings
                  },
                ),
              ],
            ),
            
            const SizedBox(height: AppTheme.spacingLarge),
            
            // Recent Activity
            Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppTheme.spacingMedium),
            
            Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading: const Icon(Icons.info),
                    title: const Text('No recent activity'),
                    subtitle: const Text('Activity will appear here'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: AppTheme.spacingSmall),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingSmall),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingMedium),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: AppTheme.spacingSmall),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
