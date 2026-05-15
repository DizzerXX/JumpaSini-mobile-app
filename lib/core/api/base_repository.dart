import 'dart:developer';
import 'package:dio/dio.dart';

abstract class BaseRepository {
  Future<T> safeCall<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on DioException catch (e) {
      log('API error [${e.response?.statusCode}]: ${e.message}', error: e);
      rethrow;
    }
  }
}
