import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/auth_repository.dart';
import '../domain/user_entity.dart';
import '../../../core/exceptions/app_exceptions.dart';

class FirebaseAuthService implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firestore;
  
  FirebaseAuthService(
    this._firebaseAuth,
    this._googleSignIn,
    this._firestore,
  );
  
  @override
  Future<UserEntity> signInWithEmail(String email, String password) async {
    try {
      final result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (result.user == null) {
        throw const AuthenticationException('Sign in failed');
      }
      
      return await _getUserEntity(result.user!);
    } on FirebaseAuthException catch (e) {
      throw AuthenticationException(
        e.message ?? 'Authentication failed',
        code: e.code,
      );
    } catch (e) {
      throw AuthenticationException('Sign in failed: $e');
    }
  }
  
  @override
  Future<UserEntity> signUpWithEmail(
    String email,
    String password,
    String firstName,
    String lastName,
  ) async {
    try {
      final result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (result.user == null) {
        throw const AuthenticationException('Sign up failed');
      }
      
      // Create user profile in Firestore
      final userEntity = UserEntity(
        id: result.user!.uid,
        email: email,
        firstName: firstName,
        lastName: lastName,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isAdmin: false,
      );
      
      await _firestore
          .collection('users')
          .doc(result.user!.uid)
          .set(userEntity.toJson());
      
      return userEntity;
    } on FirebaseAuthException catch (e) {
      throw AuthenticationException(
        e.message ?? 'Registration failed',
        code: e.code,
      );
    } catch (e) {
      throw AuthenticationException('Sign up failed: $e');
    }
  }
  
  @override
  Future<UserEntity> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      final googleAuth = await googleUser.authentication;
      
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      final result = await _firebaseAuth.signInWithCredential(credential);
      
      if (result.user == null) {
        throw const AuthenticationException('Google sign in failed');
      }
      
      // Check if user exists in Firestore, if not create
      final userDoc = await _firestore
          .collection('users')
          .doc(result.user!.uid)
          .get();
      
      UserEntity userEntity;
      if (userDoc.exists) {
        userEntity = UserEntity.fromJson(userDoc.data()!);
      } else {
        userEntity = UserEntity(
          id: result.user!.uid,
          email: result.user!.email ?? '',
          firstName: result.user!.displayName?.split(' ').first ?? '',
          lastName: result.user!.displayName?.split(' ').last ?? '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          avatarUrl: result.user!.photoURL,
          isAdmin: false,
        );
        
        await _firestore
            .collection('users')
            .doc(result.user!.uid)
            .set(userEntity.toJson());
      }
      
      return userEntity;
    } on FirebaseAuthException catch (e) {
      throw AuthenticationException(
        e.message ?? 'Google sign in failed',
        code: e.code,
      );
    } catch (e) {
      throw AuthenticationException('Google sign in failed: $e');
    }
  }
  
  @override
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
    } catch (e) {
      throw CacheException('Sign out failed: $e');
    }
  }
  
  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return null;
      
      final userDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();
      
      if (!userDoc.exists) return null;
      
      return UserEntity.fromJson(userDoc.data()!);
    } catch (e) {
      throw CacheException('Failed to get current user: $e');
    }
  }
  
  @override
  Future<UserEntity> updateProfile(UserEntity user) async {
    try {
      await _firestore
          .collection('users')
          .doc(user.id)
          .update(user.toJson());
      
      return user.copyWith(updatedAt: DateTime.now());
    } catch (e) {
      throw ServerException('Failed to update profile: $e');
    }
  }
  
  @override
  Future<String> uploadAvatar(String filePath) async {
    // This would integrate with Firebase Storage
    // For now, return a placeholder URL
    await Future.delayed(const Duration(seconds: 2));
    return 'https://placeholder.com/avatar.jpg';
  }
  
  @override
  Stream<UserEntity?> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      
      try {
        final userDoc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();
        
        if (!userDoc.exists) return null;
        
        return UserEntity.fromJson(userDoc.data()!);
      } catch (e) {
        return null;
      }
    });
  }
}

extension UserEntityExtension on UserEntity {
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'avatarUrl': avatarUrl,
      'bio': bio,
      'phone': phone,
      'website': website,
      'location': location,
      'isAdmin': isAdmin,
    };
  }
  
  static UserEntity fromJson(Map<String, dynamic> json) {
    return UserEntity(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      avatarUrl: json['avatarUrl'],
      bio: json['bio'],
      phone: json['phone'],
      website: json['website'],
      location: json['location'],
      isAdmin: json['isAdmin'],
    );
  }
}
