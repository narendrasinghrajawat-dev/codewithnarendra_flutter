import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/network_service.dart';
import '../../../../core/constants/api_endpoints.dart';

/// Education API service for making education-related API calls
class EducationApiService {
  final NetworkService _networkService;

  EducationApiService(this._networkService);

  /// Get all education entries
  Future<Map<String, dynamic>> getAllEducation() async {
    try {
      final response = await _networkService.get(
        ApiEndpoints.getEducation,
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data;
      }
      throw Exception('Invalid response format');
    } catch (e) {
      print('EducationApiService.getAllEducation error: $e');
      throw Exception('Failed to get education: ${e.toString()}');
    }
  }

  /// Get education by ID
  Future<Map<String, dynamic>> getEducationById(String id) async {
    try {
      final response = await _networkService.get(
        ApiEndpoints.getEducationById.replaceAll('{id}', id),
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data;
      }
      throw Exception('Invalid response format');
    } catch (e) {
      print('EducationApiService.getEducationById error: $e');
      throw Exception('Failed to get education: ${e.toString()}');
    }
  }

  /// Create education entry
  Future<Map<String, dynamic>> createEducation(Map<String, dynamic> data) async {
    try {
      final response = await _networkService.post(
        ApiEndpoints.createEducation,
        data: data,
      );
      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
        return responseData;
      }
      throw Exception('Invalid response format');
    } catch (e) {
      print('EducationApiService.createEducation error: $e');
      throw Exception('Failed to create education: ${e.toString()}');
    }
  }

  /// Update education entry
  Future<Map<String, dynamic>> updateEducation(String id, Map<String, dynamic> data) async {
    try {
      final response = await _networkService.put(
        ApiEndpoints.updateEducation.replaceAll('{id}', id),
        data: data,
      );
      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
        return responseData;
      }
      throw Exception('Invalid response format');
    } catch (e) {
      print('EducationApiService.updateEducation error: $e');
      throw Exception('Failed to update education: ${e.toString()}');
    }
  }

  /// Delete education entry
  Future<void> deleteEducation(String id) async {
    try {
      await _networkService.delete(
        ApiEndpoints.deleteEducation.replaceAll('{id}', id),
      );
    } catch (e) {
      print('EducationApiService.deleteEducation error: $e');
      throw Exception('Failed to delete education: ${e.toString()}');
    }
  }
}

/// Provider for EducationApiService
final educationApiServiceProvider = Provider<EducationApiService>((ref) {
  final networkService = ref.watch(networkServiceProvider);
  return EducationApiService(networkService);
});
