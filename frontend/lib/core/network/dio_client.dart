import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../errors/api_exception.dart';
import 'auth_interceptor.dart';
import 'network_config.dart';

class DioClient {
  late final Dio _dio;

  DioClient(AuthInterceptor authInterceptor) {
    _dio = Dio(BaseOptions(
      baseUrl: NetworkConfig.baseUrl,
      connectTimeout: NetworkConfig.connectTimeout,
      receiveTimeout: NetworkConfig.receiveTimeout,
      headers: {'Content-Type': 'application/json'},
      validateStatus: (status) => status != null && status < 600,
    ));

    _dio.interceptors.add(authInterceptor);

    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
      ));
    }
  }

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return _processResponse(response);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _processResponse(response);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> put(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _processResponse(response);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return _processResponse(response);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Map<String, dynamic> _processResponse(Response<dynamic> response) {
    final body = response.data;

    if (body is Map) {
      final map = Map<String, dynamic>.from(body);

      final successValue = map['success'];
      final isSuccess = successValue is bool
          ? successValue
          : (successValue.toString().toLowerCase() == 'true');

      if (!isSuccess && map.containsKey('error')) {
        final errorObj = map['error'];
        String message = 'İşlem başarısız.';
        String? errorCode;
        Map<String, List<String>>? details;

        if (errorObj is Map<String, dynamic>) {
          message = errorObj['message']?.toString() ?? message;
          errorCode = errorObj['code']?.toString();

          if (errorObj['details'] is Map) {
            final rawDetails = errorObj['details'] as Map;
            details = rawDetails.map((k, v) {
              if (v is List) {
                return MapEntry(k.toString(), v.map((e) => e.toString()).toList());
              }
              return MapEntry(k.toString(), [v.toString()]);
            });
          }
        }

        throw ApiException(
          message: message,
          errorCode: errorCode,
          details: details,
          rawData: map,
          statusCode: response.statusCode,
        );
      }
      return map;
    }

    if (body == null) return <String, dynamic>{};
    return <String, dynamic>{'data': body};
  }
}
