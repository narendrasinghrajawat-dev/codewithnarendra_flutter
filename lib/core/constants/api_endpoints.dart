/// API Endpoints - Only endpoints, no base URL
/// Base URL is configured in environment files
class ApiEndpoints {
  // Auth Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String getCurrentUser = '/auth/me';
  static const String refreshToken = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String changePassword = '/auth/change-password';
  static const String verifyEmail = '/auth/verify-email';

  // About Endpoints
  static const String getAbout = '/about';
  static const String getAboutById = '/about/{id}';
  static const String createAbout = '/about';
  static const String updateAbout = '/about/{id}';
  static const String deleteAbout = '/about/{id}';

  // Projects Endpoints
  static const String getProjects = '/projects';
  static const String getFeaturedProjects = '/projects/featured';
  static const String searchProjects = '/projects/search';
  static const String getProjectById = '/projects/{id}';
  static const String createProject = '/projects';
  static const String updateProject = '/projects/{id}';
  static const String deleteProject = '/projects/{id}';

  // Skills Endpoints
  static const String getSkills = '/skills';
  static const String getFeaturedSkills = '/skills/featured';
  static const String getSkillsByCategory = '/skills/category/{category}';
  static const String getSkillsByLevel = '/skills/level/{level}';
  static const String getSkillById = '/skills/{id}';
  static const String createSkill = '/skills';
  static const String updateSkill = '/skills/{id}';
  static const String deleteSkill = '/skills/{id}';

  // Education Endpoints
  static const String getEducation = '/education';
  static const String getEducationById = '/education/{id}';
  static const String createEducation = '/education';
  static const String updateEducation = '/education/{id}';
  static const String deleteEducation = '/education/{id}';

  // Services Endpoints
  static const String getServices = '/services';
  static const String getServiceById = '/services/{id}';
  static const String createService = '/services';
  static const String updateService = '/services/{id}';
  static const String deleteService = '/services/{id}';
}
