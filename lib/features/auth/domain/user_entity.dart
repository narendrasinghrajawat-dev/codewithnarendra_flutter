import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_entity.freezed.dart';

@freezed
class UserEntity with _$UserEntity {
  const factory UserEntity({
    required String id,
    required String email,
    required String firstName,
    required String lastName,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? avatarUrl,
    String? bio,
    String? phone,
    String? website,
    String? location,
    bool? isAdmin,
  }) = _UserEntity;
  
  String get fullName => '$firstName $lastName';
  
  bool get hasAvatar => avatarUrl != null && avatarUrl!.isNotEmpty;
  
  bool get hasBio => bio != null && bio!.isNotEmpty;
  
  bool get isUser => isAdmin == false || isAdmin == null;
  
  bool get isUserAdmin => isAdmin == true;
}
