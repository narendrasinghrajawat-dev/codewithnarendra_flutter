import 'package:codewithnarendra/core/constants/app_colors.dart';
import 'package:codewithnarendra/core/constants/app_icons.dart';
import 'package:codewithnarendra/core/constants/app_sizes.dart';
import 'package:codewithnarendra/core/constants/app_strings.dart';
import 'package:codewithnarendra/core/widgets/error_widget.dart';
import 'package:codewithnarendra/features/projects/presentation/providers/project_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/project_provider.dart';

class ProjectScreen extends ConsumerWidget {
  const ProjectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectState = ref.watch(projectStateProvider);
    final projectNotifier = ref.read(projectNotifierProvider.notifier);

    return RefreshIndicator(
      onRefresh: () async {
        await projectNotifier.getProjects();
      },
      child: projectState.status == ProjectStatus.loading
          ? const Center(child: CircularProgressIndicator())
          : projectState.status == ProjectStatus.error
              ? AppErrorWidget.fromException(
                  projectState.errorMessage,
                  onRetry: () => projectNotifier.getProjects(),
                )
              : _buildProjectList(projectState.projects?['data'] ?? [], projectNotifier),
    );
  }

  Widget _buildProjectList(List<dynamic> projects, projectNotifier) {
    if (projects.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              AppIcons.projects,
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
              'Add your first project to showcase',
              style: TextStyle(
                fontSize: AppSizes.fontSM,
                color: AppColors.grey500,
              ),
            ),
            const SizedBox(height: AppSizes.spacingLG),
            ElevatedButton(
              onPressed: () {
                projectNotifier.getProjects();
              },
              child: const Text(AppStrings.actionRefresh),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.paddingMD),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final project = projects[index];
        return _buildProjectCard(project as Map<String, dynamic>);
      },
    );
  }

  Widget _buildProjectCard(Map<String, dynamic> project) {
    // Safely get technologies as list
    final technologies = (project['technologies'] as List<dynamic>?) ?? [];

    return Card(
      elevation: AppSizes.elevationSM,
      margin: const EdgeInsets.only(bottom: AppSizes.marginMD),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
      ),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to project detail screen
        },
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingMD),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (project['isFeatured'] == true)
                    Icon(
                      AppIcons.star,
                      size: AppSizes.iconSM,
                      color: AppColors.warning,
                    ),
                  Expanded(
                    child: Text(
                      project['title']?.toString() ?? 'Untitled Project',
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
              Text(
                project['description']?.toString() ?? '',
                style: TextStyle(
                  fontSize: AppSizes.fontSM,
                  color: AppColors.grey600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSizes.spacingMD),
              if (technologies.isNotEmpty)
                Wrap(
                  spacing: AppSizes.spacingXS,
                  runSpacing: AppSizes.spacingXS,
                  children: technologies
                      .take(3)
                      .map((tech) => Chip(
                            label: Text(tech.toString()),
                            backgroundColor: AppColors.primaryLight,
                            labelStyle: TextStyle(
                              fontSize: AppSizes.fontXS,
                              color: AppColors.white,
                            ),
                          ))
                      .toList(),
                ),
              const SizedBox(height: AppSizes.spacingMD),
              Row(
                children: [
                  Icon(
                    AppIcons.link,
                    color: AppColors.primary,
                    size: AppSizes.iconSM,
                  ),
                  const SizedBox(width: AppSizes.spacingXS),
                  Expanded(
                    child: Text(
                      'View Project',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: AppSizes.fontSM,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.spacingSM),
                  IconButton(
                    icon: const Icon(AppIcons.github),
                    color: AppColors.darkOnBackground,
                    onPressed: () {
                      // TODO: Open repository URL
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

}
