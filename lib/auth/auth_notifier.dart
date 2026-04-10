import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthState {
  final AuthStatus status;
  final String? errorMessage;
  final String? userId;
  final String? email;
  final String? displayName;
  
  const AuthState({
    required this.status,
    this.errorMessage,
    this.userId,
    this.email,
    this.displayName,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? errorMessage,
    String? userId,
    String? email,
    String? displayName,
  }) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthState &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          errorMessage == other.errorMessage &&
          userId == other.userId &&
          email == other.email &&
          displayName == other.displayName;

  @override
  int get hashCode => Object.hash(status, errorMessage, userId, email, displayName);
}

class AuthNotifier extends StateNotifier<AuthState> {
  final FirebaseAuth _auth;
  
  AuthNotifier(this._auth) : super(const AuthState(status: AuthStatus.initial));

  Future<void> signInWithEmail(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);
    
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final user = result.user;
      if (user != null) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          userId: user.uid,
          email: user.email,
          displayName: user.displayName,
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> registerWithEmail(String email, String password, String displayName) async {
    state = state.copyWith(status: AuthStatus.loading);
    
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final user = result.user;
      if (user != null) {
        // Update display name
        await user.updateDisplayName(displayName);
        
        state = state.copyWith(
          status: AuthStatus.authenticated,
          userId: user.uid,
          email: user.email,
          displayName: displayName,
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        userId: null,
        email: null,
        displayName: null,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> checkAuthState() async {
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          userId: user.uid,
          email: user.email,
          displayName: user.displayName,
        );
      } else {
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
    });
  }

  void clearError() {
    state = state.copyWith(errorMessage: '');
  }
}

// Providers
final authServiceProvider = Provider<FirebaseAuth>((ref) {
  throw UnimplementedError('FirebaseAuth not initialized');
});

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final auth = FirebaseAuth.instance;
  return AuthNotifier(auth);
});

final authStateProvider = Provider<AuthState>((ref) {
  return ref.watch(authNotifierProvider);
});

final authUserProvider = Provider<User?>((ref) {
  return FirebaseAuth.instance.currentUser;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider).status == AuthStatus.authenticated;
});

final userIdProvider = Provider<String?>((ref) {
  return ref.watch(authStateProvider).userId;
});

final userEmailProvider = Provider<String?>((ref) {
  return ref.watch(authStateProvider).email;
});

final userDisplayNameProvider = Provider<String?>((ref) {
  return ref.watch(authStateProvider).displayName;
});
