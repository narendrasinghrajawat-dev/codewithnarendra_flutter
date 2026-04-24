import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/project_entity.dart';
import '../domain/portfolio_repository.dart';

class PortfolioState {
  final bool isLoading;
  final List<ProjectEntity> projects;
  final String? error;
  
  const PortfolioState({
    required this.isLoading,
    required this.projects,
    this.error,
  });
  
  PortfolioState copyWith({
    bool? isLoading,
    List<ProjectEntity>? projects,
    String? error,
  }) {
    return PortfolioState(
      isLoading: isLoading ?? this.isLoading,
      projects: projects ?? this.projects,
      error: error ?? this.error,
    );
  }
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PortfolioState &&
          runtimeType == other.runtimeType &&
          isLoading == other.isLoading &&
          projects == other.projects &&
          error == other.error;

  @override
  int get hashCode => Object.hash(isLoading, projects, error);
}

class PortfolioNotifier extends StateNotifier<PortfolioState> {
  final PortfolioRepository _portfolioRepository;
  
  PortfolioNotifier(this._portfolioRepository) : super(const PortfolioState(
    isLoading: false,
    projects: [],
  ));
  
  Future<void> loadProjects() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final projects = await _portfolioRepository.getProjects();
      state = state.copyWith(
        isLoading: false,
        projects: projects,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  Future<void> addProject(ProjectEntity project) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final newProject = await _portfolioRepository.addProject(project);
      final updatedProjects = [...state.projects, newProject];
      state = state.copyWith(
        isLoading: false,
        projects: updatedProjects,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  Future<void> updateProject(ProjectEntity project) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final updatedProject = await _portfolioRepository.updateProject(project);
      final updatedProjects = state.projects.map((p) => 
          p.id == project.id ? updatedProject : p).toList();
      state = state.copyWith(
        isLoading: false,
        projects: updatedProjects,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  Future<void> deleteProject(String projectId) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _portfolioRepository.deleteProject(projectId);
      final updatedProjects = state.projects.where((p) => p.id != projectId).toList();
      state = state.copyWith(
        isLoading: false,
        projects: updatedProjects,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Providers
final portfolioRepositoryProvider = Provider<PortfolioRepository>((ref) {
  throw UnimplementedError('PortfolioRepository not implemented');
});

final portfolioNotifierProvider = StateNotifierProvider<PortfolioNotifier, PortfolioState>((ref) {
  final repository = ref.watch(portfolioRepositoryProvider);
  return PortfolioNotifier(repository);
});

final portfolioStateProvider = Provider<PortfolioState>((ref) {
  return ref.watch(portfolioNotifierProvider);
});

final projectsProvider = Provider<List<ProjectEntity>>((ref) {
  return ref.watch(portfolioStateProvider).projects;
});
