import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../constants/api_constants.dart';
import '../errors/exceptions.dart';

class ApiClient {
  late final Dio _dio;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: true, error: true),
      );
    }

    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException e, ErrorInterceptorHandler handler) {
          final response = e.response;

          if (e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.receiveTimeout ||
              e.type == DioExceptionType.connectionError) {
            handler.reject(
              DioException(
                requestOptions: e.requestOptions,
                error: const NetworkException(
                  'Connection timed out. Check your internet connection.',
                ),
                type: e.type,
              ),
            );
            return;
          }

          if (response != null) {
            final data = response.data;
            final message = (data is Map && data['message'] != null)
                ? data['message'] as String
                : 'An unexpected error occurred.';
            final errors = (data is Map && data['errors'] != null)
                ? Map<String, dynamic>.from(data['errors'] as Map)
                : null;

            switch (response.statusCode) {
              case 404:
                handler.reject(
                  DioException(
                    requestOptions: e.requestOptions,
                    error: NotFoundException(message),
                    response: response,
                    type: e.type,
                  ),
                );
              case 422:
                handler.reject(
                  DioException(
                    requestOptions: e.requestOptions,
                    error: ValidationException(message, errors: errors),
                    response: response,
                    type: e.type,
                  ),
                );
              default:
                handler.reject(
                  DioException(
                    requestOptions: e.requestOptions,
                    error: ServerException(
                      message,
                      statusCode: response.statusCode,
                    ),
                    response: response,
                    type: e.type,
                  ),
                );
            }
            return;
          }

          handler.next(e);
        },
      ),
    );
  }

  Dio get dio => _dio;
}
