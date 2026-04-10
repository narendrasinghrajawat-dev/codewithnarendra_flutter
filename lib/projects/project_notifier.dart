import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

enum ProjectStatus {
  initial,
  loading,
  loaded,
  error,
}

class Project {
  final String id;
  final String title;
  final String description;
  final List<String> technologies;
  final List<String> images;
  final String projectUrl;
  final String repositoryUrl;
  final bool isFeatured;
  final int sortOrder;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  Project({
    required this.id,
    required this.title,
    required this.description,
    required this.technologies,
    required this.images,
    required this.projectUrl,
    required this.repositoryUrl,
    this.isFeatured = false,
    this.sortOrder = 0,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      technologies: List<String>.from(json['technologies'] as List),
      images: List<String>.from(json['images'] as List),
      projectUrl: json['projectUrl'] as String,
      repositoryUrl: json['repositoryUrl'] as String,
      isFeatured: json['isFeatured'] as bool? ?? false,
      sortOrder: json['sortOrder'] as int? ?? 0,
      createdBy: json['createdBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'technologies': technologies,
      'images': images,
      'projectUrl': projectUrl,
      'repositoryUrl': repositoryUrl,
      'isFeatured': isFeatured,
      'sortOrder': sortOrder,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Project copyWith({
    String? title,
    String? description,
    List<String>? technologies,
    List<String>? images,
    String? projectUrl,
    String? repositoryUrl,
    bool? isFeatured,
    int? sortOrder,
  }) {
    return Project(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      technologies: technologies ?? this.technologies,
      images: images ?? this.images,
      projectUrl: projectUrl ?? this.projectUrl,
      repositoryUrl: repositoryUrl ?? this.repositoryUrl,
      isFeatured: isFeatured ?? this.isFeatured,
      sortOrder: sortOrder ?? this.sortOrder,
      createdBy: createdBy,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class ProjectState {
  final ProjectStatus status;
  final List<Project> projects;
  final String? errorMessage;
  final int currentPage;
  final int totalPages;
  final bool hasMore;

  const ProjectState({
    required this.status,
    this.projects = const [],
    this.errorMessage,
    this.currentPage = 1,
    this.totalPages = 1,
    this.hasMore = false,
  });

  ProjectState copyWith({
    ProjectStatus? status,
    List<Project>? projects,
    String? errorMessage,
    int? currentPage,
    int? totalPages,
    bool? hasMore,
  }) {
    return ProjectState(
      status: status ?? this.status,
      projects: projects ?? this.projects,
      errorMessage: errorMessage ?? this.errorMessage,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class ProjectNotifier extends StateNotifier<ProjectState> {
  final Dio _dio;
  
  ProjectNotifier(this._dio) : super(const ProjectState(status: ProjectStatus.initial));

  Future<void> getProjects({int page = 1}) async {
    state = state.copyWith(status: ProjectStatus.loading);
    
    try {
      final response = await _dio.get('/projects', queryParameters: {
        'page': page.toString(),
        'limit': '10',
      });
      
      final projects = (response.data['data'] as List<dynamic>)
          .map((json) => Project.fromJson(json))
          .toList();
      
      final pagination = response.data['pagination'];
      
      state = state.copyWith(
        status: ProjectStatus.loaded,
        projects: [...state.projects, ...projects],
        currentPage: page,
        totalPages: pagination['totalPages'],
        hasMore: page < pagination['totalPages'],
      );
    } catch (e) {
      state = state.copyWith(
        status: ProjectStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> addProject(Project project) async {
    state = state.copyWith(status: ProjectStatus.loading);
    
    try {
      final response = await _dio.post('/projects', data: project.toJson());
      
      final newProject = Project.fromJson(response.data['data']);
      
      state = state.copyWith(
        status: ProjectStatus.loaded,
        projects: [...state.projects, newProject],
      );
    } catch (e) {
      state = state.copyWith(
        status: ProjectStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> updateProject(Project project) async {
    state = state.copyWith(status: ProjectStatus.loading);
    
    try {
      final response = await _dio.put('/projects/${project.id}', data: project.toJson());
      
      final updatedProject = Project.fromJson(response.data['data']);
      
      final updatedProjects = state.projects.map((p) => 
          p.id == project.id ? updatedProject : p
      ).toList();
      
      state = state.copyWith(
        status: ProjectStatus.loaded,
        projects: updatedProjects,
      );
    } catch (e) {
      state = state.copyWith(
        status: ProjectStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> deleteProject(String projectId) async {
    state = state.copyWith(status: ProjectStatus.loading);
    
    try {
      await _dio.delete('/projects/$projectId');
      
      final updatedProjects = state.projects.where((p) => p.id != projectId).toList();
      
      state = state.copyWith(
        status: ProjectStatus.loaded,
        projects: updatedProjects,
      );
    } catch (e) {
      state = state.copyWith(
        status: ProjectStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> uploadImage(String projectId, String imagePath) async {
    state = state.copyWith(status: ProjectStatus.loading);
    
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(imagePath, filename: 'project_image.jpg'),
      });
      
      final response = await _dio.post('/projects/$projectId/upload-image', data: formData);
      
      final updatedProject = Project.fromJson(response.data['data']);
      
      final updatedProjects = state.projects.map((p) => 
          p.id == projectId ? updatedProject : p
      ).toList();
      
      state = state.copyWith(
        status: ProjectStatus.loaded,
        projects: updatedProjects,
      );
    } catch (e) {
      state = state.copyWith(
        status: ProjectStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: '');
  }
}

// API Service
class ProjectApiService {
  final Dio _dio;
  
  ProjectApiService(this._dio);

  Future<List<Project>> getProjects({int page = 1}) async {
    final response = await _dio.get('/projects', queryParameters: {
      'page': page.toString(),
      'limit': '10',
    });
    
    return (response.data['data'] as List<dynamic>)
        .map((json) => Project.fromJson(json))
        .toList();
  }

  Future<Project> createProject(Map<String, dynamic> projectData) async {
    final response = await _dio.post('/projects', data: projectData);
    return Project.fromJson(response.data['data']);
  }

  Future<Project> updateProject(String projectId, Map<String, dynamic> projectData) async {
    final response = await _dio.put('/projects/$projectId', data: projectData);
    return Project.fromJson(response.data['data']);
  }

  Future<void> deleteProject(String projectId) async {
    await _dio.delete('/projects/$projectId');
  }

  Future<String> uploadProjectImage(String projectId, String imagePath) async {
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(imagePath, filename: 'project_image.jpg'),
    });
    
    final response = await _dio.post('/projects/$projectId/upload-image', data: formData);
    return response.data['data']['imageUrl'];
  }
}

// Providers
final projectApiServiceProvider = Provider<ProjectApiService>((ref) {
  final dio = ref.watch(dioProvider);
  return ProjectApiService(dio);
});

final projectNotifierProvider = StateNotifierProvider<ProjectNotifier, ProjectState>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:3000/api',
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));
  return ProjectNotifier(dio);
});

final projectStateProvider = Provider<ProjectState>((ref) {
  return ref.watch(projectNotifierProvider);
});

final projectsProvider = Provider<List<Project>>((ref) {
  return ref.watch(projectStateProvider).projects;
});

final projectLoadingProvider = Provider<bool>((ref) {
  return ref.watch(projectStateProvider).status == ProjectStatus.loading;
});

final projectErrorProvider = Provider<String?>((ref) {
  return ref.watch(projectStateProvider).errorMessage;
});

// Dio Provider
final dioProvider = Provider<Dio>((ref) {
  return Dio(BaseOptions(
    baseUrl: 'http://localhost:3000/api',
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));
});
