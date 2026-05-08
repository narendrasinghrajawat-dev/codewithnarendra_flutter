import 'package:codewithnarendra/core/constants/app_colors.dart';
import 'package:codewithnarendra/core/constants/app_icons.dart';
import 'package:codewithnarendra/core/constants/app_sizes.dart';
import 'package:codewithnarendra/core/constants/app_strings.dart';
import 'package:codewithnarendra/core/widgets/error_widget.dart';
import 'package:codewithnarendra/features/education/presentation/providers/education_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/education_provider.dart';

class EducationScreen extends ConsumerWidget {
  const EducationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final educationState = ref.watch(educationStateProvider);
    final educationNotifier = ref.read(educationNotifierProvider.notifier);

    return RefreshIndicator(
      onRefresh: () async {
        await educationNotifier.getEducation();
      },
      child: educationState.status == EducationStatus.loading
          ? const Center(child: CircularProgressIndicator())
          : educationState.status == EducationStatus.error
              ? AppErrorWidget.fromException(
                  educationState.errorMessage,
                  onRetry: () => educationNotifier.getEducation(),
                )
              : _buildEducationList(educationState.educationList?['data'] ?? [], educationNotifier),
    );
  }

  Widget _buildEducationList(List<dynamic> educationList, educationNotifier) {
    if (educationList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              AppIcons.education,
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
              'Add your education history',
              style: TextStyle(
                fontSize: AppSizes.fontSM,
                color: AppColors.grey500,
              ),
            ),
            const SizedBox(height: AppSizes.spacingLG),
            ElevatedButton(
              onPressed: () {
                educationNotifier.getEducation();
              },
              child: const Text(AppStrings.actionRefresh),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.paddingMD),
      itemCount: educationList.length,
      itemBuilder: (context, index) {
        final education = educationList[index];
        return _buildEducationCard(education as Map<String, dynamic>);
      },
    );
  }

  Widget _buildEducationCard(Map<String, dynamic> education) {
    // Parse dates from API
    DateTime? startDate;
    DateTime? endDate;
    try {
      if (education['startDate'] != null) {
        startDate = DateTime.parse(education['startDate'].toString());
      }
      if (education['endDate'] != null) {
        endDate = DateTime.parse(education['endDate'].toString());
      }
    } catch (e) {
      // Keep null if parsing fails
    }

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
            Text(
              education['institution']?.toString() ?? 'Unknown Institution',
              style: const TextStyle(
                fontSize: AppSizes.fontLG,
                fontWeight: FontWeight.bold,
                color: AppColors.darkOnBackground,
              ),
            ),
            const SizedBox(height: AppSizes.spacingSM),
            Text(
              education['degree']?.toString() ?? 'Unknown Degree',
              style: const TextStyle(
                fontSize: AppSizes.fontMD,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSizes.spacingSM),
            Text(
              education['field']?.toString() ?? 'General',
              style: TextStyle(
                fontSize: AppSizes.fontSM,
                color: AppColors.grey600,
              ),
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
                  '${startDate != null ? _formatDate(startDate) : 'N/A'} - ${endDate != null ? _formatDate(endDate) : AppStrings.educationPresent}',
                  style: TextStyle(
                    fontSize: AppSizes.fontXS,
                    color: AppColors.grey500,
                  ),
                ),
              ],
            ),
            if (education['gpa'] != null && education['gpa'].toString().isNotEmpty) ...[
              const SizedBox(height: AppSizes.spacingSM),
              Row(
                children: [
                  Icon(
                    AppIcons.education,
                    size: AppSizes.iconXS,
                    color: AppColors.grey500,
                  ),
                  const SizedBox(width: AppSizes.spacingXS),
                  Text(
                    'GPA: ${education['gpa']}',
                    style: TextStyle(
                      fontSize: AppSizes.fontXS,
                      color: AppColors.grey500,
                    ),
                  ),
                ],
              ),
            ],
            if (education['description'] != null && education['description'].toString().isNotEmpty) ...[
              const SizedBox(height: AppSizes.spacingSM),
              Text(
                education['description'].toString(),
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

}
