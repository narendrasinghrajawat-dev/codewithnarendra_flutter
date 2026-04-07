import '../project_entity.dart';

abstract class PortfolioRepository {
  Future<List<ProjectEntity>> getProjects();
  Future<ProjectEntity> addProject(ProjectEntity project);
  Future<ProjectEntity> updateProject(ProjectEntity project);
  Future<void> deleteProject(String projectId);
  Future<ProjectEntity?> getProjectById(String projectId);
}
