import 'package:freezed_annotation/freezed_annotation.dart';

part 'project_entity.freezed.dart';

@freezed
class ProjectEntity with _$ProjectEntity {
  const factory ProjectEntity({
    required String id,
    required String title,
    required String description,
    required List<String> technologies,
    required List<String> images,
    required DateTime createdAt,
    required DateTime updatedAt,
    required String projectUrl,
    required String repositoryUrl,
    bool? isFeatured,
    int? sortOrder,
  }) = _ProjectEntity;
  
  bool get hasImages => images.isNotEmpty;
  
  bool get hasProjectUrl => projectUrl.isNotEmpty;
  
  bool get hasRepositoryUrl => repositoryUrl.isNotEmpty;
}
