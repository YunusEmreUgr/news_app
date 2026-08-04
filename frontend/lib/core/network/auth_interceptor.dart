import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../storage/token_storage.dart';
import '../init/service_locator.dart';
import '../constants/api_endpoints.dart';
import 'network_config.dart';

class _QueuedRequest {
  final DioException error;
  final ErrorInterceptorHandler handler;

  _QueuedRequest({required this.error, required this.handler});
}

/// 401 Silent Token Refresh & Concurrency Interceptor
class AuthInterceptor extends Interceptor {
  bool _isRefreshing = false;
  final List<_QueuedRequest> _requestQueue = [];

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await TokenStorage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    debugPrint('🔒 401 Unauthorized captured: ${err.requestOptions.path}');

    if (_isRefreshing) {
      debugPrint('⏳ Refresh in progress, queueing request.');
      _requestQueue.add(_QueuedRequest(error: err, handler: handler));
      return;
    }

    _isRefreshing = true;

    try {
      final refreshToken = await TokenStorage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        await _performLogout(handler, err);
        return;
      }

      final refreshDio = Dio(BaseOptions(
        baseUrl: NetworkConfig.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ));

      debugPrint('🔄 Refresh token request sending...');
      final response = await refreshDio.post(
        ApiEndpoints.refreshToken,
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200 && response.data != null) {
        final newTokens = _parseTokenResponse(response.data, refreshToken);

        if (newTokens != null) {
          await TokenStorage.saveTokens(
            accessToken: newTokens['access']!,
            refreshToken: newTokens['refresh']!,
          );
          debugPrint('✅ Token successfully refreshed.');

          _retryRequest(err, handler, newTokens['access']!);
          _processQueue(newTokens['access']!);
        } else {
          await _performLogout(handler, err);
        }
      } else {
        await _performLogout(handler, err);
      }
    } catch (e) {
      debugPrint('❌ Error during token refresh: $e');
      await _performLogout(handler, err);
    } finally {
      _isRefreshing = false;
    }
  }

  void _processQueue(String newAccessToken) {
    for (final req in _requestQueue) {
      _retryRequest(req.error, req.handler, newAccessToken);
    }
    _requestQueue.clear();
  }

  Map<String, String>? _parseTokenResponse(dynamic data, String oldRefreshToken) {
    try {
      String? accessToken;
      String? refreshToken;

      if (data is Map) {
        if (data.containsKey('data') && data['data'] is Map) {
          final inner = data['data'];
          accessToken = inner['accessToken'] is Map ? inner['accessToken']['token'] : inner['accessToken'];
          refreshToken = inner['refreshToken'];
        } else {
          accessToken = data['accessToken'] is Map ? data['accessToken']['token'] : data['accessToken'];
          refreshToken = data['refreshToken'];
        }
      }

      if (accessToken != null) {
        return {
          'access': accessToken.toString(),
          'refresh': (refreshToken ?? oldRefreshToken).toString(),
        };
      }
    } catch (e) {
      debugPrint('Token parse error: $e');
    }
    return null;
  }

  Future<void> _retryRequest(DioException err, ErrorInterceptorHandler handler, String newToken) async {
    final reqOptions = err.requestOptions;
    reqOptions.headers['Authorization'] = 'Bearer $newToken';

    final retryDio = Dio(BaseOptions(
      baseUrl: reqOptions.baseUrl,
      connectTimeout: reqOptions.connectTimeout,
      receiveTimeout: reqOptions.receiveTimeout,
    ));

    try {
      final response = await retryDio.request(
        reqOptions.path,
        data: reqOptions.data,
        queryParameters: reqOptions.queryParameters,
        options: Options(
          method: reqOptions.method,
          headers: reqOptions.headers,
        ),
      );
      handler.resolve(response);
    } catch (e) {
      if (e is DioException) {
        handler.next(e);
      } else {
        handler.next(DioException(requestOptions: reqOptions, error: e));
      }
    }
  }

  Future<void> _performLogout(ErrorInterceptorHandler handler, DioException err) async {
    await TokenStorage.clearTokens();
    _requestQueue.clear();

    try {
      ServiceLocator.onLogout();
    } catch (_) {}

    handler.next(err);
  }
}
