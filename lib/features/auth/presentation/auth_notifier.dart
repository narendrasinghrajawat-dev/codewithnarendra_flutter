import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/auth_repository.dart';
import '../domain/user_entity.dart';

class AuthState {
  final bool isLoading;
  final UserEntity? user;
  final String? error;
  final bool isAuthenticated;
  
  const AuthState({
    required this.isLoading,
    this.user,
    this.error,
    required this.isAuthenticated,
  });
  
  AuthState copyWith({
    bool? isLoading,
    UserEntity? user,
    String? error,
    bool? isAuthenticated,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: error ?? this.error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthState &&
          runtimeType == other.runtimeType &&
          isLoading == other.isLoading &&
          user == other.user &&
          error == other.error &&
          isAuthenticated == other.isAuthenticated;

  @override
  int get hashCode => Object.hash(
        isLoading,
        user,
        error,
        isAuthenticated,
      );
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;
  
  AuthNotifier(this._authRepository) : super(const AuthState(
    isLoading: false,
    isAuthenticated: false,
  ));
  
  Future<void> signInWithEmail(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final user = await _authRepository.signInWithEmail(email, password);
      state = state.copyWith(
        isLoading: false,
        user: user,
        isAuthenticated: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        isAuthenticated: false,
      );
    }
  }
  
  Future<void> signUpWithEmail(
    String email,
    String password,
    String firstName,
    String lastName,
  ) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final user = await _authRepository.signUpWithEmail(
        email,
        password,
        firstName,
        lastName,
      );
      state = state.copyWith(
        isLoading: false,
        user: user,
        isAuthenticated: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        isAuthenticated: false,
      );
    }
  }
  
  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final user = await _authRepository.signInWithGoogle();
      state = state.copyWith(
        isLoading: false,
        user: user,
        isAuthenticated: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        isAuthenticated: false,
      );
    }
  }
  
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    
    try {
      await _authRepository.signOut();
      state = const AuthState(
        isLoading: false,
        isAuthenticated: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  Future<void> updateProfile(UserEntity user) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final updatedUser = await _authRepository.updateProfile(user);
      state = state.copyWith(
        isLoading: false,
        user: updatedUser,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  Future<void> uploadAvatar(String filePath) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final avatarUrl = await _authRepository.uploadAvatar(filePath);
      final updatedUser = state.user?.copyWith(avatarUrl: avatarUrl);
      state = state.copyWith(
        isLoading: false,
        user: updatedUser,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  Future<void> checkAuthState() async {
    try {
      final user = await _authRepository.getCurrentUser();
      state = state.copyWith(
        user: user,
        isAuthenticated: user != null,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isAuthenticated: false,
      );
    }
  }
  
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Providers
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  throw UnimplementedError('AuthRepository not implemented');
});

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});

final authStateProvider = Provider<AuthState>((ref) {
  return ref.watch(authNotifierProvider);
});

final userProvider = Provider<UserEntity?>((ref) {
  return ref.watch(authStateProvider).user;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider).isAuthenticated;
});
