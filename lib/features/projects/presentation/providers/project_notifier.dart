import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/get_projects_usecase.dart';
import '../../domain/usecases/create_project_usecase.dart';
import '../../domain/usecases/update_project_usecase.dart';
import '../../domain/usecases/delete_project_usecase.dart';
import 'project_state.dart';

class ProjectNotifier extends StateNotifier<ProjectState> {
  final GetProjectsUseCase _getProjectsUseCase;
  final CreateProjectUseCase _createProjectUseCase;
  final UpdateProjectUseCase _updateProjectUseCase;
  final DeleteProjectUseCase _deleteProjectUseCase;

  ProjectNotifier({
    required GetProjectsUseCase getProjectsUseCase,
    required CreateProjectUseCase createProjectUseCase,
    required UpdateProjectUseCase updateProjectUseCase,
    required DeleteProjectUseCase deleteProjectUseCase,
  })  : _getProjectsUseCase = getProjectsUseCase,
      _createProjectUseCase = createProjectUseCase,
      _updateProjectUseCase = updateProjectUseCase,
      _deleteProjectUseCase = deleteProjectUseCase,
      super(const ProjectState(status: ProjectStatus.initial));

  Future<void> getProjects() async {
    state = state.copyWith(status: ProjectStatus.loading);
    
    try {
      final projects = await _getProjectsUseCase();
      state = state.copyWith(
        status: ProjectStatus.loaded,
        projects: projects,
      );
    } catch (e) {
      state = state.copyWith(
        status: ProjectStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> createProject(Map<String, dynamic> data) async {
    state = state.copyWith(status: ProjectStatus.loading);
    
    try {
      await _createProjectUseCase(data);
      // Refresh projects list after creating
      await getProjects();
    } catch (e) {
      state = state.copyWith(
        status: ProjectStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> updateProject(String id, Map<String, dynamic> data) async {
    state = state.copyWith(status: ProjectStatus.loading);
    
    try {
      await _updateProjectUseCase(id, data);
      // Refresh projects list after updating
      await getProjects();
    } catch (e) {
      state = state.copyWith(
        status: ProjectStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> deleteProject(String id) async {
    state = state.copyWith(status: ProjectStatus.loading);
    
    try {
      await _deleteProjectUseCase(id);
      // Refresh projects list after deleting
      await getProjects();
    } catch (e) {
      state = state.copyWith(
        status: ProjectStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  void selectProject(Map<String, dynamic> project) {
    state = state.copyWith(selectedProject: project);
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
