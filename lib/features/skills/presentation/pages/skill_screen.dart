import 'package:codewithnarendra/core/constants/app_colors.dart';
import 'package:codewithnarendra/core/constants/app_icons.dart';
import 'package:codewithnarendra/core/constants/app_sizes.dart';
import 'package:codewithnarendra/core/constants/app_strings.dart';
import 'package:codewithnarendra/core/widgets/error_widget.dart';
import 'package:codewithnarendra/features/skills/presentation/providers/skill_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/skill_provider.dart';

class SkillScreen extends ConsumerWidget {
  const SkillScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final skillState = ref.watch(skillStateProvider);
    final skillNotifier = ref.read(skillNotifierProvider.notifier);

    return RefreshIndicator(
      onRefresh: () async {
        await skillNotifier.getSkills();
      },
      child: skillState.status == SkillStatus.loading
          ? const Center(child: CircularProgressIndicator())
          : skillState.status == SkillStatus.error
              ? AppErrorWidget.fromException(
                  skillState.errorMessage,
                  onRetry: () => skillNotifier.getSkills(),
                )
              : _buildSkillList(skillState.skills?['data'] ?? [], skillNotifier),
    );
  }

  Widget _buildSkillList(List<dynamic> skills, skillNotifier) {
    if (skills.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              AppIcons.skills,
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
              'Add your skills to showcase',
              style: TextStyle(
                fontSize: AppSizes.fontSM,
                color: AppColors.grey500,
              ),
            ),
            const SizedBox(height: AppSizes.spacingLG),
            ElevatedButton(
              onPressed: () {
                skillNotifier.getSkills();
              },
              child: const Text(AppStrings.actionRefresh),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.paddingMD),
      itemCount: skills.length,
      itemBuilder: (context, index) {
        final skill = skills[index];
        return _buildSkillCard(skill as Map<String, dynamic>);
      },
    );
  }

  Widget _buildSkillCard(Map<String, dynamic> skill) {
    return Card(
      elevation: AppSizes.elevationSM,
      margin: const EdgeInsets.only(bottom: AppSizes.marginMD),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (skill['icon'] != null)
                  Icon(
                    _getIconData(skill['icon'].toString()),
                    size: AppSizes.iconMD,
                    color: AppColors.primary,
                  ),
                const SizedBox(width: AppSizes.spacingSM),
                Expanded(
                  child: Text(
                    skill['name']?.toString() ?? 'Unnamed',
                    style: const TextStyle(
                      fontSize: AppSizes.fontLG,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkOnBackground,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.spacingSM),
            Row(
              children: [
                Text(
                  skill['level']?.toString() ?? 'Beginner',
                  style: const TextStyle(
                    fontSize: AppSizes.fontSM,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: AppSizes.spacingSM),
                Text(
                  '•',
                  style: TextStyle(
                    fontSize: AppSizes.fontSM,
                    color: AppColors.grey500,
                  ),
                ),
                const SizedBox(width: AppSizes.spacingSM),
                Text(
                  skill['category']?.toString() ?? 'General',
                  style: TextStyle(
                    fontSize: AppSizes.fontSM,
                    color: AppColors.grey600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.spacingSM),
            Row(
              children: [
                Icon(
                  AppIcons.calendar,
                  size: AppSizes.iconXS,
                  color: AppColors.grey500,
                ),
                const SizedBox(width: AppSizes.spacingXS),
                Text(
                  '${skill['yearsOfExperience'] ?? 0} ${(skill['yearsOfExperience'] ?? 0) == 1 ? 'year' : 'years'}',
                  style: TextStyle(
                    fontSize: AppSizes.fontXS,
                    color: AppColors.grey500,
                  ),
                ),
              ],
            ),
            if (skill['description'] != null && skill['description'].toString().isNotEmpty) ...[
              const SizedBox(height: AppSizes.spacingSM),
              Text(
                skill['description'].toString(),
                style: TextStyle(
                  fontSize: AppSizes.fontXS,
                  color: AppColors.grey600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    // TODO: Map icon names to IconData
    return AppIcons.projects;
  }

}
