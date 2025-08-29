import 'package:dio/dio.dart';

class DioService {
  static final DioService _instance = DioService._internal();

  factory DioService() {
    return _instance;
  }

  DioService._internal() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(milliseconds: 5000),
        receiveTimeout: const Duration(milliseconds: 3000),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      LogInterceptor(responseBody: true, requestBody: true),
    );
  }

  late Dio _dio;
  Dio get dio => _dio;
}
