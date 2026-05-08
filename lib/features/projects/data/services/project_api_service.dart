import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/network_service.dart';
import '../../../../core/constants/api_endpoints.dart';

/// Project API service for making project-related API calls
class ProjectApiService {
  final NetworkService _networkService;

  ProjectApiService(this._networkService);

  /// Get all projects
  Future<Map<String, dynamic>> getAllProjects() async {
    try {
      final response = await _networkService.get(
        ApiEndpoints.getProjects,
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data;
      }
      throw Exception('Invalid response format');
    } catch (e) {
      print('ProjectApiService.getAllProjects error: $e');
      throw Exception('Failed to get projects: ${e.toString()}');
    }
  }

  /// Get featured projects
  Future<Map<String, dynamic>> getFeaturedProjects() async {
    try {
      final response = await _networkService.get(
        ApiEndpoints.getFeaturedProjects,
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data;
      }
      throw Exception('Invalid response format');
    } catch (e) {
      print('ProjectApiService.getFeaturedProjects error: $e');
      throw Exception('Failed to get featured projects: ${e.toString()}');
    }
  }

  /// Search projects
  Future<Map<String, dynamic>> searchProjects(String query) async {
    try {
      final response = await _networkService.get(
        ApiEndpoints.searchProjects,
        queryParameters: {'q': query},
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data;
      }
      throw Exception('Invalid response format');
    } catch (e) {
      print('ProjectApiService.searchProjects error: $e');
      throw Exception('Failed to search projects: ${e.toString()}');
    }
  }

  /// Get project by ID
  Future<Map<String, dynamic>> getProjectById(String id) async {
    try {
      final response = await _networkService.get(
        ApiEndpoints.getProjectById.replaceAll('{id}', id),
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data;
      }
      throw Exception('Invalid response format');
    } catch (e) {
      print('ProjectApiService.getProjectById error: $e');
      throw Exception('Failed to get project: ${e.toString()}');
    }
  }

  /// Create project
  Future<Map<String, dynamic>> createProject(Map<String, dynamic> data) async {
    try {
      final response = await _networkService.post(
        ApiEndpoints.createProject,
        data: data,
      );
      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
        return responseData;
      }
      throw Exception('Invalid response format');
    } catch (e) {
      print('ProjectApiService.createProject error: $e');
      throw Exception('Failed to create project: ${e.toString()}');
    }
  }

  /// Update project
  Future<Map<String, dynamic>> updateProject(String id, Map<String, dynamic> data) async {
    try {
      final response = await _networkService.put(
        ApiEndpoints.updateProject.replaceAll('{id}', id),
        data: data,
      );
      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
        return responseData;
      }
      throw Exception('Invalid response format');
    } catch (e) {
      print('ProjectApiService.updateProject error: $e');
      throw Exception('Failed to update project: ${e.toString()}');
    }
  }

  /// Delete project
  Future<void> deleteProject(String id) async {
    try {
      await _networkService.delete(
        ApiEndpoints.deleteProject.replaceAll('{id}', id),
      );
    } catch (e) {
      print('ProjectApiService.deleteProject error: $e');
      throw Exception('Failed to delete project: ${e.toString()}');
    }
  }
}

/// Provider for ProjectApiService
final projectApiServiceProvider = Provider<ProjectApiService>((ref) {
  final networkService = ref.watch(networkServiceProvider);
  return ProjectApiService(networkService);
});
