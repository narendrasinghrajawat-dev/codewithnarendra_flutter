import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/services/auth_api_service.dart';
import '../../data/models/user_model.dart';
import '../../../../core/services/network_service.dart';

/// Auth states
enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

/// Auth state class
class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? errorMessage;
  final bool isInitialized;

  AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.isInitialized = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? errorMessage,
    bool? isInitialized,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;
  bool get hasError => status == AuthStatus.error;
}

/// Auth controller with Riverpod
class AuthController extends StateNotifier<AuthState> {
  final AuthApiService _authApiService;
  final NetworkService _networkService;

  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userDataKey = 'user_data';

  AuthController(this._authApiService, this._networkService)
      : super(AuthState()) {
    _loadStoredToken();
    _checkAuthStatus();
  }

  /// Load stored token from SharedPreferences
  Future<void> _loadStoredToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      if (token != null) {
        _networkService.setAuthToken(token);
      }
    } catch (e) {
      print('Error loading stored token: $e');
    }
  }

  /// Save token to SharedPreferences
  Future<void> _saveToken(String token, {String? refreshToken}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      if (refreshToken != null) {
        await prefs.setString(_refreshTokenKey, refreshToken);
      }
    } catch (e) {
      print('Error saving token: $e');
    }
  }

  /// Clear token from SharedPreferences
  Future<void> _clearStoredTokens() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_refreshTokenKey);
      await prefs.remove(_userDataKey);
    } catch (e) {
      print('Error clearing stored tokens: $e');
    }
  }

  /// Save user data to SharedPreferences
  Future<void> _saveUserData(Map<String, dynamic> userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = jsonEncode(userData);
      await prefs.setString(_userDataKey, userJson);
    } catch (e) {
      print('Error saving user data: $e');
    }
  }

  /// Load user data from SharedPreferences
  Future<Map<String, dynamic>?> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userDataKey);
      if (userJson != null) {
        return jsonDecode(userJson) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error loading user data: $e');
      return null;
    }
  }

  /// Check authentication status
  Future<void> _checkAuthStatus() async {
    try {
      state = state.copyWith(status: AuthStatus.loading);

      // First, try to load from local storage
      final storedUserData = await _loadUserData();
      if (storedUserData != null) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: UserModel.fromMap(storedUserData),
          isInitialized: true,
        );
        return;
      }

      // If no local data, try API
      final response = await _authApiService.getCurrentUser();
      // Response shape: { success, message, data: { ...userFields } }
      final userData = (response['data'] ?? response) as Map<String, dynamic>;
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: UserModel.fromMap(userData),
        isInitialized: true,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        isInitialized: true,
      );
    }
  }

  /// Login with email and password
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

      final response = await _authApiService.login(
        email: email,
        password: password,
      );

      // Response shape: { success, message, data: { ...userFields, tokens: { accessToken, refreshToken } } }
      final data = (response['data'] ?? response) as Map<String, dynamic>;
      final tokens = data['tokens'] as Map<String, dynamic>;
      final accessToken = tokens['accessToken'] as String;
      final refreshToken = tokens['refreshToken'] as String?;

      // Set auth token in network service
      _networkService.setAuthToken(accessToken);

      // Save tokens to storage
      await _saveToken(accessToken, refreshToken: refreshToken);

      // Save user data to storage
      await _saveUserData(data);

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: UserModel.fromMap(data),
        isInitialized: true,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Register a new user
  Future<bool> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? displayName,
  }) async {
    try {
      state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

      final response = await _authApiService.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );

      // Response shape: { success, message, data: { user: {...}, tokens: { accessToken, refreshToken } } }
      final data = (response['data'] ?? response) as Map<String, dynamic>;
      final tokens = data['tokens'] as Map<String, dynamic>;
      final accessToken = tokens['accessToken'] as String;
      final refreshToken = tokens['refreshToken'] as String?;

      // Set auth token in network service
      _networkService.setAuthToken(accessToken);

      // Save tokens to storage
      await _saveToken(accessToken, refreshToken: refreshToken);

      final userData = data['user'] as Map<String, dynamic>;

      // Save user data to storage
      await _saveUserData(userData);

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: UserModel.fromMap(userData),
        isInitialized: true,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      await _authApiService.logout();
    } catch (e) {
      // Ignore logout errors
    } finally {
      _networkService.clearAuthToken();
      // Clear stored tokens
      await _clearStoredTokens();
      state = AuthState(status: AuthStatus.unauthenticated);
    }
  }

  /// Update user profile
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    try {
      state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
      
      final userData = await _authApiService.updateProfile(data);
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: UserModel.fromMap(userData),
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
      
      await _authApiService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      state = state.copyWith(status: state.user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated);
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Forgot password
  Future<bool> forgotPassword(String email) async {
    try {
      state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
      
      await _authApiService.forgotPassword(email);
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Reset password
  Future<bool> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
      
      await _authApiService.resetPassword(
        token: token,
        newPassword: newPassword,
      );
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// Provider for AuthController
final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  final authApiService = ref.watch(authApiServiceProvider);
  final networkService = ref.watch(networkServiceProvider);
  return AuthController(authApiService, networkService);
});
