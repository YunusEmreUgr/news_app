abstract class AppConstants {
  static const String appName = 'Enterprise Template';
  static const String appVersion = '1.0.0';
  
  // Storage Keys
  static const String keyAccessToken = 'ACCESS_TOKEN';
  static const String keyRefreshToken = 'REFRESH_TOKEN';
  static const String keyThemeMode = 'THEME_MODE';
  static const String keyLocale = 'LOCALE';

  // Network Timeouts
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
