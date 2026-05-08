import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/service_api_service.dart';
import 'service_notifier.dart';
import 'service_state.dart';

// Notifier Provider
final serviceNotifierProvider = StateNotifierProvider<ServiceNotifier, ServiceState>((ref) {
  final apiService = ref.watch(serviceApiServiceProvider);
  return ServiceNotifier(apiService: apiService);
});

// State Provider
final serviceStateProvider = Provider<ServiceState>((ref) {
  return ref.watch(serviceNotifierProvider);
});

// Services List Provider
final servicesProvider = Provider((ref) {
  return ref.watch(serviceStateProvider).services;
});

// Loading Provider
final serviceLoadingProvider = Provider<bool>((ref) {
  return ref.watch(serviceStateProvider).status == ServiceStatus.loading;
});

// Error Provider
final serviceErrorProvider = Provider<String?>((ref) {
  return ref.watch(serviceStateProvider).errorMessage;
});
