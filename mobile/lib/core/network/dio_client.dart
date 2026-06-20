import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';
import '../errors/failure.dart';

final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient(const FlutterSecureStorage());
});

class DioClient {
  DioClient(this._storage) {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(milliseconds: AppConstants.connectTimeoutMs),
      receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeoutMs),
      headers: {'Accept': 'application/json'},
    ));

    _dio.interceptors.add(_AuthInterceptor(_storage, _dio));
  }

  late final Dio _dio;
  final FlutterSecureStorage _storage;

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) =>
      _dio.get(path, queryParameters: queryParameters);

  Future<Response> post(String path, {dynamic data}) =>
      _dio.post(path, data: data);

  Future<Response> put(String path, {dynamic data}) =>
      _dio.put(path, data: data);

  Future<Response> delete(String path) => _dio.delete(path);
}

class _AuthInterceptor extends Interceptor {
  _AuthInterceptor(this._storage, Dio dio);

  final FlutterSecureStorage _storage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.read(key: AppConstants.tokenKey);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    switch (err.response?.statusCode) {
      case 401:
        handler.reject(DioException(
          requestOptions: err.requestOptions,
          error: const AuthFailure(),
          type: DioExceptionType.badResponse,
          response: err.response,
        ));
      case 404:
        handler.reject(DioException(
          requestOptions: err.requestOptions,
          error: const NotFoundFailure(),
          type: DioExceptionType.badResponse,
          response: err.response,
        ));
      default:
        handler.reject(err);
    }
  }
}

Failure mapDioError(DioException e) {
  if (e.error is Failure) return e.error as Failure;

  return switch (e.type) {
    DioExceptionType.connectionError ||
    DioExceptionType.connectionTimeout =>
      const NetworkFailure(),
    DioExceptionType.badResponse => switch (e.response?.statusCode) {
        401 => const AuthFailure(),
        422 => ValidationFailure(
            e.response?.data['message'] ?? 'Validation failed.',
            errors: (e.response?.data['errors'] as Map<String, dynamic>?)?.map(
              (k, v) => MapEntry(k, List<String>.from(v)),
            ),
          ),
        _ => ServerFailure(e.response?.data['message'] ?? 'Server error.'),
      },
    _ => const ServerFailure(),
  };
}
