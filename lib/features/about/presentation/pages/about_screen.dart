import 'package:codewithnarendra/core/constants/app_colors.dart';
import 'package:codewithnarendra/core/constants/app_icons.dart';
import 'package:codewithnarendra/core/constants/app_sizes.dart';
import 'package:codewithnarendra/core/constants/app_strings.dart';
import 'package:codewithnarendra/core/config/app_theme_colors.dart';
import 'package:codewithnarendra/core/config/app_icons.dart' as app_icons;
import 'package:codewithnarendra/features/about/presentation/providers/about_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/about_provider.dart';

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aboutState = ref.watch(aboutStateProvider);
    final aboutNotifier = ref.read(aboutNotifierProvider.notifier);

    return RefreshIndicator(
      onRefresh: () async {
        await aboutNotifier.getAbout();
      },
      child: aboutState.status == AboutStatus.loading
          ? const Center(child: CircularProgressIndicator())
          : aboutState.status == AboutStatus.error
              ? _buildErrorWidget(aboutState.errorMessage!, aboutNotifier)
              : aboutState.about != null
                  ? _buildAboutContent(aboutState.about!)
                  : _buildEmptyWidget(aboutNotifier),
    );
  }

  Widget _buildAboutContent(about) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Section
          Center(
            child: Column(
              children: [
                app_icons.AppIcons.logoWithContainer(
                  size: 120,
                  backgroundColor: Colors.white,
                ),
                const SizedBox(height: 24),
                Text(
                  about['title'] ?? 'Narendra',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkOnBackground,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppThemeColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Full Stack Developer',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppThemeColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Description Card
          _buildSectionCard(
            title: 'About Me',
            child: Text(
              about['description'] ?? 'No description available',
              style: const TextStyle(
                fontSize: 16,
                height: 1.6,
                color: AppColors.grey600,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Resume Button
          if (about['resumeUrl'] != null) _buildResumeButton(about['resumeUrl']),
          if (about['resumeUrl'] != null) const SizedBox(height: 24),

          // Contact Info Card
          _buildContactInfo(about),
          const SizedBox(height: 24),

          // Social Links Card
          _buildSocialLinks(about),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.darkOnBackground,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildResumeButton(String resumeUrl) {
    return ElevatedButton.icon(
      onPressed: () {
        // TODO: Open resume URL
      },
      icon: const Icon(AppIcons.document),
      label: const Text(AppStrings.portfolioDownloadResume),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingLG,
          vertical: AppSizes.paddingMD,
        ),
      ),
    );
  }

  Widget _buildContactInfo(about) {
    return _buildSectionCard(
      title: 'Contact Information',
      child: Column(
        children: [
          if (about['email'] != null) _buildContactItem(Icons.email, about['email']),
          if (about['phone'] != null) _buildContactItem(Icons.phone, about['phone']),
          if (about['location'] != null) _buildContactItem(Icons.location_on, about['location']),
          if (about['website'] != null) _buildContactItem(Icons.language, about['website']),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.paddingSM),
      child: Row(
        children: [
          Icon(icon, size: AppSizes.iconSM, color: AppColors.primary),
          const SizedBox(width: AppSizes.spacingSM),
          Text(
            text,
            style: TextStyle(
              fontSize: AppSizes.fontSM,
              color: AppColors.grey600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialLinks(about) {
    return _buildSectionCard(
      title: 'Social Links',
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          if (about['linkedin'] != null)
            _buildSocialButton(Icons.link, about['linkedin'], 'LinkedIn'),
          if (about['github'] != null)
            _buildSocialButton(Icons.code, about['github'], 'GitHub'),
          if (about['twitter'] != null)
            _buildSocialButton(Icons.alternate_email, about['twitter'], 'Twitter'),
        ],
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, String url, String label) {
    return Container(
      decoration: BoxDecoration(
        color: AppThemeColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        onPressed: () {
          // TODO: Open social URL
        },
        icon: Icon(icon, color: AppThemeColors.primary),
        tooltip: label,
      ),
    );
  }

  Widget _buildErrorWidget(String errorMessage, aboutNotifier) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            AppIcons.error,
            size: AppSizes.iconXXXXL,
            color: AppColors.error,
          ),
          const SizedBox(height: AppSizes.spacingMD),
          Text(
            errorMessage,
            style: const TextStyle(
              fontSize: AppSizes.fontMD,
              color: AppColors.error,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.spacingMD),
          ElevatedButton(
            onPressed: () {
              aboutNotifier.getAbout();
            },
            child: const Text(AppStrings.actionRetry),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget(aboutNotifier) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            AppIcons.about,
            size: AppSizes.iconXXXXL,
            color: AppColors.grey400,
          ),
          const SizedBox(height: AppSizes.spacingMD),
          const Text(
            AppStrings.statusEmpty,
            style: TextStyle(
              fontSize: AppSizes.fontMD,
              color: AppColors.grey600,
            ),
          ),
          const SizedBox(height: AppSizes.spacingSM),
          const Text(
            'Add your about information',
            style: TextStyle(
              fontSize: AppSizes.fontSM,
              color: AppColors.grey500,
            ),
          ),
          const SizedBox(height: AppSizes.spacingLG),
          ElevatedButton(
            onPressed: () {
              aboutNotifier.getAbout();
            },
            child: const Text(AppStrings.actionRefresh),
          ),
        ],
      ),
    );
  }
}
