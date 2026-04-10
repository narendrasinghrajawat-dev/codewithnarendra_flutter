import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

enum SkillStatus {
  initial,
  loading,
  loaded,
  error,
}

class Skill {
  final String id;
  final String name;
  final String level;
  final String category;
  final int? yearsOfExperience;
  final DateTime createdAt;
  final DateTime updatedAt;

  Skill({
    required this.id,
    required this.name,
    required this.level,
    required this.category,
    this.yearsOfExperience,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Skill.fromJson(Map<String, dynamic> json) {
    return Skill(
      id: json['id'] as String,
      name: json['name'] as String,
      level: json['level'] as String,
      category: json['category'] as String,
      yearsOfExperience: json['yearsOfExperience'] as int?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'level': level,
      'category': category,
      'yearsOfExperience': yearsOfExperience,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class SkillState {
  final SkillStatus status;
  final List<Skill> skills;
  final String? errorMessage;

  const SkillState({
    required this.status,
    this.skills = const [],
    this.errorMessage,
  });

  SkillState copyWith({
    SkillStatus? status,
    List<Skill>? skills,
    String? errorMessage,
  }) {
    return SkillState(
      status: status ?? this.status,
      skills: skills ?? this.skills,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class SkillNotifier extends StateNotifier<SkillState> {
  final Dio _dio;
  
  SkillNotifier(this._dio) : super(const SkillState(status: SkillStatus.initial));

  Future<void> getSkills() async {
    state = state.copyWith(status: SkillStatus.loading);
    
    try {
      final response = await _dio.get('/skills');
      
      final skills = (response.data['data'] as List<dynamic>)
          .map((json) => Skill.fromJson(json))
          .toList();
      
      state = state.copyWith(
        status: SkillStatus.loaded,
        skills: skills,
      );
    } catch (e) {
      state = state.copyWith(
        status: SkillStatus.error,
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

final skillNotifierProvider = StateNotifierProvider<SkillNotifier, SkillState>((ref) {
  final dio = ref.watch(dioProvider);
  return SkillNotifier(dio);
});

final skillStateProvider = Provider<SkillState>((ref) {
  return ref.watch(skillNotifierProvider);
});

final skillsProvider = Provider<List<Skill>>((ref) {
  return ref.watch(skillStateProvider).skills;
});

final skillLoadingProvider = Provider<bool>((ref) {
  return ref.watch(skillStateProvider).status == SkillStatus.loading;
});

final skillErrorProvider = Provider<String?>((ref) {
  return ref.watch(skillStateProvider).errorMessage;
});
