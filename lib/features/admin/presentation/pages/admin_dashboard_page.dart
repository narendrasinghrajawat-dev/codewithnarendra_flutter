import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/app_theme_colors.dart';
import '../../../../core/services/localization_service.dart';
import '../../../education/presentation/providers/education_provider.dart';
import '../../../education/presentation/providers/education_state.dart';
import '../../../projects/presentation/providers/project_provider.dart';
import '../../../projects/presentation/providers/project_state.dart';
import '../../../services/presentation/providers/service_provider.dart';
import '../../../services/presentation/providers/service_state.dart';
import '../../../skills/presentation/providers/skill_provider.dart';
import '../../../skills/presentation/providers/skill_state.dart';
import '../widgets/admin_stats_card.dart';
import '../widgets/admin_dialogs.dart';

/// Admin Dashboard with stats and overview
class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localizations = ref.watch(localizationStateProvider);
    final isHindi = localizations.language == AppLanguage.hi;

    // Watch data providers
    final skillState = ref.watch(skillStateProvider);
    final projectState = ref.watch(projectStateProvider);
    final educationState = ref.watch(educationStateProvider);
    final serviceState = ref.watch(serviceStateProvider);

    // Calculate stats
    final totalSkills = skillState.skills?['data']?.length ?? 0;
    final totalProjects = projectState.projects?['data']?.length ?? 0;
    final totalEducation = educationState.educationList?['data']?.length ?? 0;
    final totalServices = serviceState.services?.length ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome section
          _buildWelcomeSection(context, isDark, isHindi),
          const SizedBox(height: 24),
          
          // Stats Grid
          _buildStatsSection(
            context,
            isDark,
            isHindi,
            totalSkills: totalSkills,
            totalProjects: totalProjects,
            totalEducation: totalEducation,
            totalServices: totalServices,
            isLoading: skillState.status == SkillStatus.loading ||
                      projectState.status == ProjectStatus.loading ||
                      educationState.status == EducationStatus.loading ||
                      serviceState.status == ServiceStatus.loading,
          ),
          const SizedBox(height: 24),
          
          // Recent Activity & Quick Actions
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth >= 900) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildQuickActions(context, isDark, isHindi),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: _buildSystemStatus(context, isDark, isHindi),
                    ),
                  ],
                );
              }
              return Column(
                children: [
                  _buildQuickActions(context, isDark, isHindi),
                  const SizedBox(height: 20),
                  _buildSystemStatus(context, isDark, isHindi),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context, bool isDark, bool isHindi) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade600,
            Colors.purple.shade600,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isHindi ? 'स्वागत है, व्यवस्थापक!' : 'Welcome, Admin!',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isHindi
                      ? 'अपने पोर्टफोलियो को यहां से प्रबंधित करें।'
                      : 'Manage your portfolio from here.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.admin_panel_settings,
              size: 48,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(
    BuildContext context,
    bool isDark,
    bool isHindi, {
    required int totalSkills,
    required int totalProjects,
    required int totalEducation,
    required int totalServices,
    required bool isLoading,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 900
            ? 4
            : constraints.maxWidth > 600
                ? 2
                : 2;

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            AdminStatsCard(
              title: isHindi ? 'कौशल' : 'Skills',
              value: totalSkills.toString(),
              icon: Icons.psychology,
              color: Colors.blue,
              isLoading: isLoading,
              subtitle: isHindi ? 'कुल' : 'Total',
            ),
            AdminStatsCard(
              title: isHindi ? 'परियोजनाएं' : 'Projects',
              value: totalProjects.toString(),
              icon: Icons.folder_open,
              color: Colors.green,
              isLoading: isLoading,
              subtitle: isHindi ? 'कुल' : 'Total',
            ),
            AdminStatsCard(
              title: isHindi ? 'शिक्षा' : 'Education',
              value: totalEducation.toString(),
              icon: Icons.school,
              color: Colors.orange,
              isLoading: isLoading,
              subtitle: isHindi ? 'कुल' : 'Total',
            ),
            AdminStatsCard(
              title: isHindi ? 'सेवाएं' : 'Services',
              value: totalServices.toString(),
              icon: Icons.design_services,
              color: Colors.purple,
              isLoading: isLoading,
              subtitle: isHindi ? 'कुल' : 'Total',
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickActions(BuildContext context, bool isDark, bool isHindi) {
    final actions = [
      _QuickAction(
        icon: Icons.psychology,
        label: isHindi ? 'कौशल जोड़ें' : 'Add Skill',
        color: Colors.blue,
        route: '/admin/skills',
      ),
      _QuickAction(
        icon: Icons.folder_open,
        label: isHindi ? 'परियोजना जोड़ें' : 'Add Project',
        color: Colors.green,
        route: '/admin/projects',
      ),
      _QuickAction(
        icon: Icons.school,
        label: isHindi ? 'शिक्षा जोड़ें' : 'Add Education',
        color: Colors.orange,
        route: '/admin/education',
      ),
      _QuickAction(
        icon: Icons.design_services,
        label: isHindi ? 'सेवा जोड़ें' : 'Add Service',
        color: Colors.purple,
        route: '/admin/services',
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppThemeColors.darkSurface : AppThemeColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isHindi ? 'त्वरित कार्रवाई' : 'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.5,
            children: actions.map((action) {
              return _buildQuickActionButton(context, action, isDark);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(BuildContext context, _QuickAction action, bool isDark) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: action.color.withOpacity(0.3),
        ),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to specific tab
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                action.color.withOpacity(0.1),
                action.color.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: action.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  action.icon,
                  color: action.color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  action.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: action.color,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSystemStatus(BuildContext context, bool isDark, bool isHindi) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppThemeColors.darkSurface : AppThemeColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isHindi ? 'सिस्टम स्थिति' : 'System Status',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildStatusItem(
            context,
            isHindi ? 'API सर्वर' : 'API Server',
            'http://192.168.31.141:3000/api',
            true,
            isDark,
          ),
          const Divider(height: 24),
          _buildStatusItem(
            context,
            isHindi ? 'डेटाबेस' : 'Database',
            'MongoDB Atlas',
            true,
            isDark,
          ),
          const Divider(height: 24),
          _buildStatusItem(
            context,
            isHindi ? 'स्टोरेज' : 'Storage',
            'Firebase Storage',
            true,
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(
    BuildContext context,
    String label,
    String value,
    bool isOnline,
    bool isDark,
  ) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: isOnline ? Colors.green : Colors.red,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final String route;

  _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.route,
  });
}
