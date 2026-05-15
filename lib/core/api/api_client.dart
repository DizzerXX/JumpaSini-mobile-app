import 'package:dio/dio.dart';

class ApiClient {
  late final Dio _dio;

  // 10.0.2.2 routes to host machine localhost from Android emulator.
  // Change to your dev machine's LAN IP for physical device testing.
  static const String _baseUrl = 'http://10.0.2.2:8000/api';

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Accept': 'application/json'},
      ),
    );
  }

  Dio get dio => _dio;
}
