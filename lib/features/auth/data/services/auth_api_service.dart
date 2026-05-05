import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/network_service.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/constants/api_endpoints.dart';

/// Auth API service for making authentication-related API calls
class AuthApiService {
  final NetworkService _networkService;

  AuthApiService(this._networkService);

  /// Login with email and password
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _networkService.post<Map<String, dynamic>>(
        ApiEndpoints.login,
        data: {
          'email': email,
          'password': password,
        },
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// Register a new user
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final response = await _networkService.post<Map<String, dynamic>>(
        ApiEndpoints.register,
        data: {
          'email': email,
          'password': password,
          'firstName': firstName,
          'lastName': lastName,
        },
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      await _networkService.post<void>(
        ApiEndpoints.logout,
      );
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// Get current user profile
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await _networkService.get<Map<String, dynamic>>(
        ApiEndpoints.getCurrentUser,
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// Update user profile
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _networkService.post<Map<String, dynamic>>(
        ApiEndpoints.getCurrentUser,
        data: data,
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _networkService.post<void>(
        ApiEndpoints.changePassword,
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// Forgot password
  Future<void> forgotPassword(String email) async {
    try {
      await _networkService.post<void>(
        ApiEndpoints.forgotPassword,
        data: {'email': email},
      );
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// Reset password
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      await _networkService.post<void>(
        ApiEndpoints.resetPassword,
        data: {
          'token': token,
          'password': newPassword,
        },
      );
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// Verify email
  Future<void> verifyEmail(String token) async {
    try {
      await _networkService.post<void>(
        ApiEndpoints.verifyEmail,
        data: {'token': token},
      );
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  Exception _handleAuthError(dynamic error) {
    if (error is AppException) {
      return error;
    }
    return NetworkException('Something went wrong');
  }
}

/// Provider for AuthApiService
final authApiServiceProvider = Provider<AuthApiService>((ref) {
  final networkService = ref.watch(networkServiceProvider);
  return AuthApiService(networkService);
});
