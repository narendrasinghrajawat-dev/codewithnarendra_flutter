import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
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

  AuthController(this._authApiService, this._networkService)
      : super(AuthState()) {
    _checkAuthStatus();
  }

  /// Check authentication status
  Future<void> _checkAuthStatus() async {
    try {
      state = state.copyWith(status: AuthStatus.loading);
      final userData = await _authApiService.getCurrentUser();
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: UserModel.fromMap(userData),
      );
    } catch (e) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
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

      final tokens = response['tokens'] as Map<String, dynamic>;
      final accessToken = tokens['accessToken'] as String;

      // Set auth token in network service
      _networkService.setAuthToken(accessToken);

      // Store tokens locally (you can implement secure storage)
      // TODO: Store tokens securely

      final adminData = response['user'] as Map<String, dynamic>;
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: UserModel.fromMap(adminData),
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
  }) async {
    try {
      state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
      
      final response = await _authApiService.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );

      final tokens = response['tokens'] as Map<String, dynamic>;
      final accessToken = tokens['accessToken'] as String;

      // Set auth token in network service
      _networkService.setAuthToken(accessToken);

      // Store tokens locally
      // TODO: Store tokens securely

      final adminData = response['user'] as Map<String, dynamic>;
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: UserModel.fromMap(adminData),
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
      // TODO: Clear stored tokens
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
