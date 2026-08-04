import '../constants/api_endpoints.dart';
import '../constants/app_constants.dart';

class NetworkConfig {
  static String get baseUrl => ApiEndpoints.baseUrl;
  static Duration get connectTimeout => AppConstants.connectTimeout;
  static Duration get receiveTimeout => AppConstants.receiveTimeout;
}
