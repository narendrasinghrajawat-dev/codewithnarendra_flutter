import 'package:codewithnarendra/core/config/app_theme_colors.dart';
import 'package:codewithnarendra/core/config/app_icons.dart' as app_icons;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Static data model for About screen
/// Later this will be replaced with API data
class AboutData {
  final String name;
  final String title;
  final String subtitle;
  final String description;
  final String experience;
  final String projects;
  final String clients;
  final List<SkillData> skills;
  final List<ServiceData> services;
  final ContactData contact;
  final List<SocialLink> socialLinks;

  const AboutData({
    required this.name,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.experience,
    required this.projects,
    required this.clients,
    required this.skills,
    required this.services,
    required this.contact,
    required this.socialLinks,
  });
}

class SkillData {
  final String name;
  final double percentage;
  final IconData icon;
  final Color color;

  const SkillData({
    required this.name,
    required this.percentage,
    required this.icon,
    required this.color,
  });
}

class ServiceData {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const ServiceData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class ContactData {
  final String email;
  final String phone;
  final String location;
  final String website;

  const ContactData({
    required this.email,
    required this.phone,
    required this.location,
    required this.website,
  });
}

class SocialLink {
  final String name;
  final String url;
  final IconData icon;

  const SocialLink({
    required this.name,
    required this.url,
    required this.icon,
  });
}

/// Static data for the about screen
/// TODO: Replace with API call in future
final staticAboutData = AboutData(
  name: 'Narendra Singh',
  title: 'Full Stack Developer',
  subtitle: 'Flutter & NestJS Expert',
  description:
      'Passionate full-stack developer with expertise in building modern, scalable applications. Specialized in Flutter for cross-platform mobile development and NestJS for robust backend solutions. Committed to writing clean, maintainable code and delivering exceptional user experiences.',
  experience: '5+',
  projects: '50+',
  clients: '30+',
  skills: const [
    SkillData(
      name: 'Flutter',
      percentage: 95,
      icon: Icons.flutter_dash,
      color: Colors.blue,
    ),
    SkillData(
      name: 'Dart',
      percentage: 90,
      icon: Icons.code,
      color: Colors.cyan,
    ),
    SkillData(
      name: 'NestJS',
      percentage: 85,
      icon: Icons.api,
      color: Colors.red,
    ),
    SkillData(
      name: 'TypeScript',
      percentage: 88,
      icon: Icons.javascript,
      color: Colors.orange,
    ),
    SkillData(
      name: 'Node.js',
      percentage: 82,
      icon: Icons.terminal,
      color: Colors.green,
    ),
    SkillData(
      name: 'MongoDB',
      percentage: 80,
      icon: Icons.storage,
      color: Colors.teal,
    ),
  ],
  services: const [
    ServiceData(
      title: 'Mobile App Development',
      description:
          'Cross-platform mobile apps using Flutter with beautiful UI and smooth performance',
      icon: Icons.smartphone,
      color: Colors.purple,
    ),
    ServiceData(
      title: 'Web Development',
      description:
          'Responsive web applications with modern frameworks and best practices',
      icon: Icons.web,
      color: Colors.indigo,
    ),
    ServiceData(
      title: 'Backend Development',
      description:
          'Scalable APIs and server-side solutions using NestJS and Node.js',
      icon: Icons.cloud,
      color: Colors.blue,
    ),
    ServiceData(
      title: 'Database Design',
      description:
          'Efficient database architecture with MongoDB, PostgreSQL, and Firebase',
      icon: Icons.storage,
      color: Colors.teal,
    ),
  ],
  contact: const ContactData(
    email: 'narendra@example.com',
    phone: '+91 98765 43210',
    location: 'Madhya Pradesh, India',
    website: 'www.codewithnarendra.com',
  ),
  socialLinks: const [
    SocialLink(
      name: 'LinkedIn',
      url: 'https://linkedin.com/in/narendra',
      icon: Icons.link,
    ),
    SocialLink(
      name: 'GitHub',
      url: 'https://github.com/narendra',
      icon: Icons.code,
    ),
    SocialLink(
      name: 'Twitter',
      url: 'https://twitter.com/narendra',
      icon: Icons.alternate_email,
    ),
    SocialLink(
      name: 'Instagram',
      url: 'https://instagram.com/narendra',
      icon: Icons.camera_alt,
    ),
  ],
);

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // TODO: Refresh data from API
            await Future.delayed(const Duration(seconds: 1));
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                // Hero Section
                _buildHeroSection(context, l10n, isDark),

                // Stats Section
                _buildStatsSection(context, l10n, isDark),

                // About Section
                _buildAboutSection(context, l10n, isDark),

                // Skills Section
                _buildSkillsSection(context, l10n, isDark),

                // Services Section
                _buildServicesSection(context, l10n, isDark),

                // Contact Section
                _buildContactSection(context, l10n, isDark),

                // Social Links
                _buildSocialSection(context, l10n, isDark),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, AppLocalizations l10n, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  AppThemeColors.primary.withOpacity(0.8),
                  AppThemeColors.secondary.withOpacity(0.6),
                ]
              : [
                  AppThemeColors.primary,
                  AppThemeColors.secondary,
                ],
        ),
      ),
      child: Column(
        children: [
          // Profile Image with animated container
          Hero(
            tag: 'profile',
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipOval(
                child: app_icons.AppIcons.logoCustom(
                  size: 132,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Name with animation
          Text(
            staticAboutData.name,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),

          // Title
          Text(
            staticAboutData.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 4),

          // Subtitle
          Text(
            staticAboutData.subtitle,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white60,
            ),
          ),
          const SizedBox(height: 24),

          // CTA Button
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Download resume
            },
            icon: const Icon(Icons.download),
            label: const Text('Download CV'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppThemeColors.primary,
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context, AppLocalizations l10n, bool isDark) {
    return Transform.translate(
      offset: const Offset(0, -30),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              staticAboutData.experience,
              'Years Experience',
              isDark,
            ),
            _buildDivider(),
            _buildStatItem(
              staticAboutData.projects,
              'Projects Completed',
              isDark,
            ),
            _buildDivider(),
            _buildStatItem(
              staticAboutData.clients,
              'Happy Clients',
              isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, bool isDark) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppThemeColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 40,
      color: Colors.grey[300],
    );
  }

  Widget _buildAboutSection(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
  ) {
    return _buildSectionContainer(
      context: context,
      title: 'About Me',
      child: Text(
        staticAboutData.description,
        style: TextStyle(
          fontSize: 16,
          height: 1.7,
          color: isDark ? Colors.grey[300] : Colors.grey[700],
        ),
        textAlign: TextAlign.center,
      ),
      isDark: isDark,
    );
  }

  Widget _buildSkillsSection(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
  ) {
    return _buildSectionContainer(
      context: context,
      title: 'My Skills',
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        alignment: WrapAlignment.center,
        children: staticAboutData.skills
            .map((skill) => _buildSkillChip(skill, isDark))
            .toList(),
      ),
      isDark: isDark,
    );
  }

  Widget _buildServicesSection(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
  ) {
    return _buildSectionContainer(
      context: context,
      title: 'Services',
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.75,
        ),
        itemCount: staticAboutData.services.length,
        itemBuilder: (context, index) {
          return _buildServiceCard(
            staticAboutData.services[index],
            isDark,
          );
        },
      ), 
      isDark: isDark,
    );
  }

  Widget _buildContactSection(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
  ) {
    return _buildSectionContainer(
      context: context,
      title: 'Get In Touch',
      child: Column(
        children: [
          _buildContactItem(
            Icons.email,
            'Email',
            staticAboutData.contact.email,
            isDark,
          ),
          _buildContactItem(
            Icons.phone,
            'Phone',
            staticAboutData.contact.phone,
            isDark,
          ),
          _buildContactItem(
            Icons.location_on,
            'Location',
            staticAboutData.contact.location,
            isDark,
          ),
          _buildContactItem(
            Icons.language,
            'Website',
            staticAboutData.contact.website,
            isDark,
          ),
        ],
      ),
      isDark: isDark,
    );
  }

  Widget _buildSocialSection(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
  ) {
    return _buildSectionContainer(
      context: context,
      title: 'Follow Me',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: staticAboutData.socialLinks
            .map((social) => _buildSocialButton(social, isDark))
            .toList(),
      ),
      isDark: isDark,
    );
  }

  Widget _buildSocialButton(SocialLink social, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: IconButton(
        onPressed: () {
          // TODO: Open social URL
        },
        icon: Icon(social.icon),
        style: IconButton.styleFrom(
          backgroundColor:
              isDark ? Colors.grey[800] : AppThemeColors.primary.withOpacity(0.1),
          foregroundColor: AppThemeColors.primary,
          padding: const EdgeInsets.all(12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        tooltip: social.name,
      ),
    );
  }

  Widget _buildSkillChip(SkillData skill, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: skill.color.withOpacity(isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: skill.color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            skill.icon,
            size: 18,
            color: skill.color,
          ),
          const SizedBox(width: 8),
          Text(
            skill.name,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : skill.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(ServiceData service, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: service.color.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: service.color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: service.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              service.icon,
              color: service.color,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            service.title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            service.description,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(
    IconData icon,
    String label,
    String value,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppThemeColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: AppThemeColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionContainer({
    required BuildContext context,
    required String title,
    required Widget child,
    required bool isDark,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppThemeColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 50,
            height: 3,
            decoration: BoxDecoration(
              color: AppThemeColors.secondary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}
