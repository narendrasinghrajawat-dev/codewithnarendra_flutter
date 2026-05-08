import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/network_service.dart';
import '../../../../core/constants/api_endpoints.dart';

/// Skill API service for making skill-related API calls
class SkillApiService {
  final NetworkService _networkService;

  SkillApiService(this._networkService);

  /// Get all skills
  Future<Map<String, dynamic>> getAllSkills() async {
    print('========== SKILL API CALL START ==========');
    print('SkillApiService.getAllSkills called');
    try {
      final response = await _networkService.get(
        ApiEndpoints.getSkills,
      );
      print('SkillApiService: Response received');
      print('SkillApiService: Response.runtimeType = ${response.runtimeType}');
      
      // Extract data from Dio response
      final data = response.data;
      print('SkillApiService: data.runtimeType = ${data.runtimeType}');
      print('SkillApiService: data = $data');
      
      if (data is Map<String, dynamic>) {
        print('SkillApiService: Data is Map<String, dynamic> - SUCCESS');
        print('========== SKILL API CALL END ==========');
        return data;
      }
      throw Exception('Invalid response format: expected Map, got ${data.runtimeType}');
    } catch (e) {
      print('SkillApiService.getAllSkills ERROR: $e');
      print('========== SKILL API CALL END (ERROR) ==========');
      throw Exception('Failed to get skills: ${e.toString()}');
    }
  }

  /// Get featured skills
  Future<Map<String, dynamic>> getFeaturedSkills() async {
    try {
      final response = await _networkService.get(
        ApiEndpoints.getFeaturedSkills,
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data;
      }
      throw Exception('Invalid response format');
    } catch (e) {
      print('SkillApiService.getFeaturedSkills error: $e');
      throw Exception('Failed to get featured skills: ${e.toString()}');
    }
  }

  /// Get skills by category
  Future<Map<String, dynamic>> getSkillsByCategory(String category) async {
    try {
      final response = await _networkService.get(
        ApiEndpoints.getSkillsByCategory.replaceAll('{category}', category),
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data;
      }
      throw Exception('Invalid response format');
    } catch (e) {
      print('SkillApiService.getSkillsByCategory error: $e');
      throw Exception('Failed to get skills by category: ${e.toString()}');
    }
  }

  /// Get skills by level
  Future<Map<String, dynamic>> getSkillsByLevel(String level) async {
    try {
      final response = await _networkService.get(
        ApiEndpoints.getSkillsByLevel.replaceAll('{level}', level),
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data;
      }
      throw Exception('Invalid response format');
    } catch (e) {
      print('SkillApiService.getSkillsByLevel error: $e');
      throw Exception('Failed to get skills by level: ${e.toString()}');
    }
  }

  /// Get skill by ID
  Future<Map<String, dynamic>> getSkillById(String id) async {
    try {
      final response = await _networkService.get(
        ApiEndpoints.getSkillById.replaceAll('{id}', id),
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data;
      }
      throw Exception('Invalid response format');
    } catch (e) {
      print('SkillApiService.getSkillById error: $e');
      throw Exception('Failed to get skill: ${e.toString()}');
    }
  }

  /// Create skill
  Future<Map<String, dynamic>> createSkill(Map<String, dynamic> data) async {
    try {
      final response = await _networkService.post(
        ApiEndpoints.createSkill,
        data: data,
      );
      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
        return responseData;
      }
      throw Exception('Invalid response format');
    } catch (e) {
      print('SkillApiService.createSkill error: $e');
      throw Exception('Failed to create skill: ${e.toString()}');
    }
  }

  /// Update skill
  Future<Map<String, dynamic>> updateSkill(String id, Map<String, dynamic> data) async {
    try {
      final response = await _networkService.put(
        ApiEndpoints.updateSkill.replaceAll('{id}', id),
        data: data,
      );
      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
        return responseData;
      }
      throw Exception('Invalid response format');
    } catch (e) {
      print('SkillApiService.updateSkill error: $e');
      throw Exception('Failed to update skill: ${e.toString()}');
    }
  }

  /// Delete skill
  Future<void> deleteSkill(String id) async {
    try {
      await _networkService.delete(
        ApiEndpoints.deleteSkill.replaceAll('{id}', id),
      );
    } catch (e) {
      print('SkillApiService.deleteSkill error: $e');
      throw Exception('Failed to delete skill: ${e.toString()}');
    }
  }
}

/// Provider for SkillApiService
final skillApiServiceProvider = Provider<SkillApiService>((ref) {
  final networkService = ref.watch(networkServiceProvider);
  return SkillApiService(networkService);
});
