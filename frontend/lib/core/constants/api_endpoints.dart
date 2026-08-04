import '../config/app_config.dart';

abstract class ApiEndpoints {
  // Base URL (Dynamic per environment & platform)
  static String get baseUrl => AppConfig.instance.apiBaseUrl;

  // Auth Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh';
  static const String getUserClaims = '/auth/claims';

  // User Endpoints
  static const String userProfile = '/users/profile';
  static const String updateProfile = '/users/update';
}
