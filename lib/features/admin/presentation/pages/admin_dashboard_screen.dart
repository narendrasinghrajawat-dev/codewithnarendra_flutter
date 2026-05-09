import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../core/widgets/common_text.dart';
import '../widgets/admin_stats_card.dart';
import '../widgets/admin_shell.dart';
import '../../../../core/widgets/common_button.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/constants/app_sizes.dart';
import '../controllers/admin_auth_controller.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(adminAuthControllerProvider);
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        title: Text(l10n.adminDashboard),
        backgroundColor: isDark ? Colors.grey[800] : Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: l10n.authLogout,
            onPressed: () {
              ref.read(adminAuthControllerProvider.notifier).logout();
              // Navigate to admin login
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: ResponsiveContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonText.veryLarge(
                '${l10n.authWelcome}, ${authState.admin?.fullName ?? l10n.navAdmin}',
                fontWeight: FontWeight.bold,
              ),
              const ResponsiveSpacing(mobile: AppSizes.spacingSM),
              CommonText.small(
                l10n.adminManageContent,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
              const ResponsiveSpacing(mobile: AppSizes.spacingXL),
              
              // Dashboard content will be added here
              _buildDashboardCards(context, isDark, l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardCards(BuildContext context, bool isDark, AppLocalizations l10n) {
    final cards = [
      _DashboardCard(
        title: l10n.portfolioSkills,
        subtitle: l10n.adminSkillsManagement,
        icon: Icons.psychology,
        color: Colors.blue,
        onTap: () {},
      ),
      _DashboardCard(
        title: l10n.portfolioProjects,
        subtitle: l10n.adminManagement,
        icon: Icons.work,
        color: Colors.green,
        onTap: () {},
      ),
      _DashboardCard(
        title: l10n.aboutServices,
        subtitle: l10n.adminManagement,
        icon: Icons.design_services,
        color: Colors.orange,
        onTap: () {},
      ),
      _DashboardCard(
        title: l10n.portfolioEducation,
        subtitle: l10n.adminEducationManagement,
        icon: Icons.school,
        color: Colors.purple,
        onTap: () {},
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 1200;
        final isTablet = constraints.maxWidth > 600;
        
        if (isDesktop) {
          return GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: cards,
          );
        } else if (isTablet) {
          return GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: cards,
          );
        } else {
          return Column(
            children: cards.map((card) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: card,
            )).toList(),
          );
        }
      },
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Card(
      elevation: 2,
      color: isDark ? Colors.grey[800] : Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CommonText.medium(
                title,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
              const SizedBox(height: 4),
              CommonText.small(
                subtitle,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
