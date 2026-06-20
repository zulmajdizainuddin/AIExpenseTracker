import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../models/user_model.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(dioClientProvider));
});

class AuthService {
  AuthService(this._client);
  final DioClient _client;

  Future<({UserModel user, String token})> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _client.post('/auth/login', data: {
        'email':    email,
        'password': password,
      });
      final data = res.data['data'];
      return (
        user:  UserModel.fromJson(data['user']),
        token: data['token'] as String,
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<({UserModel user, String token})> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final res = await _client.post('/auth/register', data: {
        'name':                  name,
        'email':                 email,
        'password':              password,
        'password_confirmation': password,
      });
      final data = res.data['data'];
      return (
        user:  UserModel.fromJson(data['user']),
        token: data['token'] as String,
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<void> logout() async {
    try {
      await _client.post('/auth/logout');
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
