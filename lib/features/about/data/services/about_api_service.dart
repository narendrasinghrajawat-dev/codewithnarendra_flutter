import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/network_service.dart';
import '../../../../core/constants/api_endpoints.dart';

/// About API service for making about-related API calls
class AboutApiService {
  final NetworkService _networkService;

  AboutApiService(this._networkService);

  /// Get all about entries
  Future<Map<String, dynamic>> getAllAbout() async {
    try {
      final response = await _networkService.get<Map<String, dynamic>>(
        ApiEndpoints.getAbout,
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to get about: ${e.toString()}');
    }
  }

  /// Get about by ID
  Future<Map<String, dynamic>> getAboutById(String id) async {
    try {
      final response = await _networkService.get<Map<String, dynamic>>(
        ApiEndpoints.getAboutById.replaceAll('{id}', id),
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to get about: ${e.toString()}');
    }
  }

  /// Create about entry
  Future<Map<String, dynamic>> createAbout(Map<String, dynamic> data) async {
    try {
      final response = await _networkService.post<Map<String, dynamic>>(
        ApiEndpoints.createAbout,
        data: data,
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to create about: ${e.toString()}');
    }
  }

  /// Update about entry
  Future<Map<String, dynamic>> updateAbout(String id, Map<String, dynamic> data) async {
    try {
      final response = await _networkService.put<Map<String, dynamic>>(
        ApiEndpoints.updateAbout.replaceAll('{id}', id),
        data: data,
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to update about: ${e.toString()}');
    }
  }

  /// Delete about entry
  Future<void> deleteAbout(String id) async {
    try {
      await _networkService.delete(
        ApiEndpoints.deleteAbout.replaceAll('{id}', id),
      );
    } catch (e) {
      throw Exception('Failed to delete about: ${e.toString()}');
    }
  }
}

/// Provider for AboutApiService
final aboutApiServiceProvider = Provider<AboutApiService>((ref) {
  final networkService = ref.watch(networkServiceProvider);
  return AboutApiService(networkService);
});
