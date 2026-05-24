import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../utils/token_manager.dart';
import '../constants/api_constants.dart';

@singleton
class ApiClient {
  late Dio _dio;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await TokenManager.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          print('--- API ERROR ---');
          print('URL: ${e.requestOptions.uri}');
          print('Method: ${e.requestOptions.method}');
          print('Headers: ${e.requestOptions.headers}');
          print('Status Code: ${e.response?.statusCode}');
          print('Response: ${e.response?.data}');
          print('Message: ${e.message}');
          print('-----------------');

          if (e.response?.statusCode == 401) {
            await TokenManager.clearToken();
            // هنا يمكن إضافة logic للانتقال لشاشة تسجيل الدخول إذا لزم الأمر
          }

          return handler.next(e);
        },
      ),
    );
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParams}) async {
    return await _dio.get(path, queryParameters: queryParams);
  }

  Future<Response> post(String path, {dynamic data}) async {
    return await _dio.post(path, data: data);
  }

  Future<Response> put(String path, {dynamic data}) async {
    return await _dio.put(path, data: data);
  }

  Future<Response> delete(String path, {dynamic data}) async {
    return await _dio.delete(path, data: data);
  }

  // طرق مخصصة سابقة (تم الإبقاء عليها للتوافق)
  Future<Response> getKpiSummary() async {
    return await get(ApiConstants.kpiSummary);
  }

  Future<Response> login(String username, String password) async {
    return await post(
      ApiConstants.login,
      data: {'username': username, 'password': password},
    );
  }
}
