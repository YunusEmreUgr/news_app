import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:frontend_template/core/config/app_config.dart';

class AppLogger {
  AppLogger._();

  static void d(String message, {String tag = 'DEBUG'}) {
    _log('💡 [$tag] $message', name: tag);
  }

  static void i(String message, {String tag = 'INFO'}) {
    _log('ℹ️ [$tag] $message', name: tag);
  }

  static void w(String message, {String tag = 'WARNING'}) {
    _log('⚠️ [$tag] $message', name: tag);
  }

  static void e(String message, {Object? error, StackTrace? stackTrace, String tag = 'ERROR'}) {
    _log('❌ [$tag] $message', error: error, stackTrace: stackTrace, name: tag);
  }

  static void _log(String message, {Object? error, StackTrace? stackTrace, required String name}) {
    if (kDebugMode || AppConfig.instance.enableLogging) {
      developer.log(
        message,
        name: name,
        error: error,
        stackTrace: stackTrace,
        time: DateTime.now(),
      );
    }
  }
}
