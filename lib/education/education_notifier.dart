import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

enum EducationStatus {
  initial,
  loading,
  loaded,
  error,
}

class Education {
  final String id;
  final String institution;
  final String degree;
  final String field;
  final DateTime startDate;
  final DateTime? endDate;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  Education({
    required this.id,
    required this.institution,
    required this.degree,
    required this.field,
    required this.startDate,
    this.endDate,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Education.fromJson(Map<String, dynamic> json) {
    return Education(
      id: json['id'] as String,
      institution: json['institution'] as String,
      degree: json['degree'] as String,
      field: json['field'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate'] as String) : null,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'institution': institution,
      'degree': degree,
      'field': field,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class EducationState {
  final EducationStatus status;
  final List<Education> education;
  final String? errorMessage;

  const EducationState({
    required this.status,
    this.education = const [],
    this.errorMessage,
  });

  EducationState copyWith({
    EducationStatus? status,
    List<Education>? education,
    String? errorMessage,
  }) {
    return EducationState(
      status: status ?? this.status,
      education: education ?? this.education,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class EducationNotifier extends StateNotifier<EducationState> {
  final Dio _dio;
  
  EducationNotifier(this._dio) : super(const EducationState(status: EducationStatus.initial));

  Future<void> getEducation() async {
    state = state.copyWith(status: EducationStatus.loading);
    
    try {
      final response = await _dio.get('/education');
      
      final education = (response.data['data'] as List<dynamic>)
          .map((json) => Education.fromJson(json))
          .toList();
      
      state = state.copyWith(
        status: EducationStatus.loaded,
        education: education,
      );
    } catch (e) {
      state = state.copyWith(
        status: EducationStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: '');
  }
}

// Providers
final dioProvider = Provider<Dio>((ref) {
  return Dio(BaseOptions(
    baseUrl: 'http://localhost:3000/api',
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));
});

final educationNotifierProvider = StateNotifierProvider<EducationNotifier, EducationState>((ref) {
  final dio = ref.watch(dioProvider);
  return EducationNotifier(dio);
});

final educationStateProvider = Provider<EducationState>((ref) {
  return ref.watch(educationNotifierProvider);
});

final educationProvider = Provider<List<Education>>((ref) {
  return ref.watch(educationStateProvider).education;
});

final educationLoadingProvider = Provider<bool>((ref) {
  return ref.watch(educationStateProvider).status == EducationStatus.loading;
});

final educationErrorProvider = Provider<String?>((ref) {
  return ref.watch(educationStateProvider).errorMessage;
});
