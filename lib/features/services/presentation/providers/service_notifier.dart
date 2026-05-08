import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/service_model.dart';
import '../../data/services/service_api_service.dart';
import 'service_state.dart';

class ServiceNotifier extends StateNotifier<ServiceState> {
  final ServiceApiService _apiService;

  ServiceNotifier({required ServiceApiService apiService})
      : _apiService = apiService,
        super(const ServiceState());

  Future<void> getServices() async {
    state = state.copyWith(status: ServiceStatus.loading);

    try {
      final response = await _apiService.getAllServices();
      final data = response['data'] as List<dynamic>;
      final services = data.map((json) => ServiceModel.fromJson(json)).toList();

      state = state.copyWith(
        status: ServiceStatus.loaded,
        services: services,
      );
    } catch (e) {
      state = state.copyWith(
        status: ServiceStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> refreshServices() async {
    await getServices();
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  Future<void> createService(Map<String, dynamic> data) async {
    state = state.copyWith(status: ServiceStatus.loading);

    try {
      await _apiService.createService(data);
      await getServices();
    } catch (e) {
      state = state.copyWith(
        status: ServiceStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> updateService(String id, Map<String, dynamic> data) async {
    state = state.copyWith(status: ServiceStatus.loading);

    try {
      await _apiService.updateService(id, data);
      await getServices();
    } catch (e) {
      state = state.copyWith(
        status: ServiceStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> deleteService(String id) async {
    state = state.copyWith(status: ServiceStatus.loading);

    try {
      await _apiService.deleteService(id);
      await getServices();
    } catch (e) {
      state = state.copyWith(
        status: ServiceStatus.error,
        errorMessage: e.toString(),
      );
    }
  }
}
