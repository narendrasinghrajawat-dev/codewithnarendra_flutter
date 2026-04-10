import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

enum AboutStatus {
  initial,
  loading,
  loaded,
  error,
}

class About {
  final String id;
  final String title;
  final String description;
  final String? resumeUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  About({
    required this.id,
    required this.title,
    required this.description,
    this.resumeUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory About.fromJson(Map<String, dynamic> json) {
    return About(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      resumeUrl: json['resumeUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'resumeUrl': resumeUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class AboutState {
  final AboutStatus status;
  final About? about;
  final String? errorMessage;

  const AboutState({
    required this.status,
    this.about,
    this.errorMessage,
  });

  AboutState copyWith({
    AboutStatus? status,
    About? about,
    String? errorMessage,
  }) {
    return AboutState(
      status: status ?? this.status,
      about: about ?? this.about,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class AboutNotifier extends StateNotifier<AboutState> {
  final Dio _dio;
  
  AboutNotifier(this._dio) : super(const AboutState(status: AboutStatus.initial));

  Future<void> getAbout() async {
    state = state.copyWith(status: AboutStatus.loading);
    
    try {
      final response = await _dio.get('/about');
      
      final about = About.fromJson(response.data['data']);
      
      state = state.copyWith(
        status: AboutStatus.loaded,
        about: about,
      );
    } catch (e) {
      state = state.copyWith(
        status: AboutStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> updateAbout(About about) async {
    state = state.copyWith(status: AboutStatus.loading);
    
    try {
      final response = await _dio.put('/about', data: about.toJson());
      
      final updatedAbout = About.fromJson(response.data['data']);
      
      state = state.copyWith(
        status: AboutStatus.loaded,
        about: updatedAbout,
      );
    } catch (e) {
      state = state.copyWith(
        status: AboutStatus.error,
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

final aboutNotifierProvider = StateNotifierProvider<AboutNotifier, AboutState>((ref) {
  final dio = ref.watch(dioProvider);
  return AboutNotifier(dio);
});

final aboutStateProvider = Provider<AboutState>((ref) {
  return ref.watch(aboutNotifierProvider);
});

final aboutProvider = Provider<About?>((ref) {
  return ref.watch(aboutStateProvider).about;
});

final aboutLoadingProvider = Provider<bool>((ref) {
  return ref.watch(aboutStateProvider).status == AboutStatus.loading;
});

final aboutErrorProvider = Provider<String?>((ref) {
  return ref.watch(aboutStateProvider).errorMessage;
});
