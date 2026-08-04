import 'package:dio/dio.dart';

/// Backend structured error response model
class ApiException implements Exception {
  final String message;
  final String? errorCode;
  final int? statusCode;
  final Map<String, List<String>>? details;
  final dynamic rawData;

  ApiException({
    required this.message,
    this.errorCode,
    this.statusCode,
    this.details,
    this.rawData,
  });

  factory ApiException.fromDioError(DioException error) {
    String message = 'Bir ağ hatası oluştu.';
    String? errorCode;
    Map<String, List<String>>? details;
    final statusCode = error.response?.statusCode;
    final responseData = error.response?.data;

    if (responseData is Map<String, dynamic>) {
      if (responseData.containsKey('message')) {
        message = responseData['message'].toString();
      } else if (responseData.containsKey('error')) {
        final err = responseData['error'];
        if (err is Map) {
          message = err['message']?.toString() ?? message;
          errorCode = err['code']?.toString();
          if (err['details'] is Map) {
            final rawDetails = err['details'] as Map;
            details = rawDetails.map((k, v) {
              if (v is List) {
                return MapEntry(k.toString(), v.map((e) => e.toString()).toList());
              }
              return MapEntry(k.toString(), [v.toString()]);
            });
          }
        } else if (err is String) {
          message = err;
        }
      }
    } else {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          message = 'Bağlantı zaman aşımına uğradı. Lütfen internetinizi kontrol edin.';
          break;
        case DioExceptionType.badResponse:
          message = 'Sunucu hatası ($statusCode).';
          break;
        case DioExceptionType.cancel:
          message = 'İstek iptal edildi.';
          break;
        case DioExceptionType.connectionError:
          message = 'Sunucuya ulaşılamıyor.';
          break;
        default:
          message = 'Beklenmeyen bir hata oluştu.';
      }
    }

    return ApiException(
      message: message,
      errorCode: errorCode,
      statusCode: statusCode,
      details: details,
      rawData: responseData,
    );
  }

  @override
  String toString() => 'ApiException: $message (Code: $errorCode, Status: $statusCode)';
}
