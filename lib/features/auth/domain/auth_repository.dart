import '../user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> signInWithEmail(String email, String password);
  Future<UserEntity> signUpWithEmail(String email, String password, String firstName, String lastName);
  Future<UserEntity> signInWithGoogle();
  Future<void> signOut();
  Future<UserEntity?> getCurrentUser();
  Future<UserEntity> updateProfile(UserEntity user);
  Future<String> uploadAvatar(String filePath);
  Stream<UserEntity?> get authStateChanges;
}
