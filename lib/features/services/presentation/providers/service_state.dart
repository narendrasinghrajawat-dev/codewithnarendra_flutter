import '../../data/models/service_model.dart';

enum ServiceStatus { initial, loading, loaded, error }

class ServiceState {
  final ServiceStatus status;
  final List<ServiceModel> services;
  final String? errorMessage;

  const ServiceState({
    this.status = ServiceStatus.initial,
    this.services = const [],
    this.errorMessage,
  });

  ServiceState copyWith({
    ServiceStatus? status,
    List<ServiceModel>? services,
    String? errorMessage,
  }) {
    return ServiceState(
      status: status ?? this.status,
      services: services ?? this.services,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
