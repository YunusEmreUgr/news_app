import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../errors/global_error_handler.dart';
import '../storage/cache_storage.dart';
import '../utils/app_logger.dart';
import 'service_locator.dart';

class AppInitializer {
  static Future<void> init(
    GlobalKey<NavigatorState> navigatorKey, {
    AppEnvironment environment = AppEnvironment.dev,
    bool useMockData = true, // Default to Mock/Demo Mode for instant standalone testing!
  }) async {
    WidgetsFlutterBinding.ensureInitialized();
    AppConfig.init(environment: environment, useMockData: useMockData);
    GlobalErrorHandler.init();
    await CacheStorage.init();
    ServiceLocator.setup(navigatorKey);
    AppLogger.i('App initialized in [${environment.name}] mode (MockData: $useMockData)', tag: 'APP_INIT');
  }
}

