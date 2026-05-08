import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/network_service.dart';
import '../../../../core/constants/api_endpoints.dart';

/// Service API service for making service-related API calls
class ServiceApiService {
  final NetworkService _networkService;

  ServiceApiService(this._networkService);

  /// Get all active services
  Future<Map<String, dynamic>> getAllServices() async {
    try {
      final response = await _networkService.get(
        ApiEndpoints.getServices,
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data;
      }
      throw Exception('Invalid response format');
    } catch (e) {
      print('ServiceApiService.getAllServices error: $e');
      throw Exception('Failed to get services: ${e.toString()}');
    }
  }

  /// Get service by ID
  Future<Map<String, dynamic>> getServiceById(String id) async {
    try {
      final response = await _networkService.get(
        ApiEndpoints.getServiceById.replaceAll('{id}', id),
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data;
      }
      throw Exception('Invalid response format');
    } catch (e) {
      print('ServiceApiService.getServiceById error: $e');
      throw Exception('Failed to get service: ${e.toString()}');
    }
  }

  /// Create service
  Future<Map<String, dynamic>> createService(Map<String, dynamic> data) async {
    try {
      final response = await _networkService.post(
        ApiEndpoints.createService,
        data: data,
      );
      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
        return responseData;
      }
      throw Exception('Invalid response format');
    } catch (e) {
      print('ServiceApiService.createService error: $e');
      throw Exception('Failed to create service: ${e.toString()}');
    }
  }

  /// Update service
  Future<Map<String, dynamic>> updateService(String id, Map<String, dynamic> data) async {
    try {
      final response = await _networkService.put(
        ApiEndpoints.updateService.replaceAll('{id}', id),
        data: data,
      );
      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
        return responseData;
      }
      throw Exception('Invalid response format');
    } catch (e) {
      print('ServiceApiService.updateService error: $e');
      throw Exception('Failed to update service: ${e.toString()}');
    }
  }

  /// Delete service
  Future<void> deleteService(String id) async {
    try {
      await _networkService.delete(
        ApiEndpoints.deleteService.replaceAll('{id}', id),
      );
    } catch (e) {
      print('ServiceApiService.deleteService error: $e');
      throw Exception('Failed to delete service: ${e.toString()}');
    }
  }
}

/// Provider for ServiceApiService
final serviceApiServiceProvider = Provider<ServiceApiService>((ref) {
  final networkService = ref.watch(networkServiceProvider);
  return ServiceApiService(networkService);
});
