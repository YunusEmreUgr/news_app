import 'package:flutter/foundation.dart';
import 'package:frontend_template/core/utils/app_logger.dart';

class GlobalErrorHandler {
  GlobalErrorHandler._();

  static void init() {
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      AppLogger.e(
        'Uncaught Flutter UI Error: ${details.exception}',
        error: details.exception,
        stackTrace: details.stack,
        tag: 'GLOBAL_UI_ERROR',
      );
    };

    PlatformDispatcher.instance.onError = (Object error, StackTrace stackTrace) {
      AppLogger.e(
        'Uncaught Platform Async Error: $error',
        error: error,
        stackTrace: stackTrace,
        tag: 'GLOBAL_ASYNC_ERROR',
      );
      return true;
    };
  }
}
