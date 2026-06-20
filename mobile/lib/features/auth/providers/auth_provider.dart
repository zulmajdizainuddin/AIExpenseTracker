import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/constants/app_constants.dart';
import '../data/auth_service.dart';
import '../models/user_model.dart';

final _storageProvider = Provider<FlutterSecureStorage>((_) => const FlutterSecureStorage());

final authStateProvider = AsyncNotifierProvider<AuthNotifier, UserModel?>(AuthNotifier.new);

class AuthNotifier extends AsyncNotifier<UserModel?> {
  @override
  Future<UserModel?> build() async {
    final storage  = ref.read(_storageProvider);
    final userJson = await storage.read(key: AppConstants.userKey);

    if (userJson == null) return null;

    return UserModel.fromJson(jsonDecode(userJson));
  }

  Future<void> login({required String email, required String password}) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final service = ref.read(authServiceProvider);
      final storage = ref.read(_storageProvider);

      final result = await service.login(email: email, password: password);

      await Future.wait([
        storage.write(key: AppConstants.tokenKey, value: result.token),
        storage.write(key: AppConstants.userKey,  value: jsonEncode(result.user.toJson())),
      ]);

      return result.user;
    });
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final service = ref.read(authServiceProvider);
      final storage = ref.read(_storageProvider);

      final result = await service.register(name: name, email: email, password: password);

      await Future.wait([
        storage.write(key: AppConstants.tokenKey, value: result.token),
        storage.write(key: AppConstants.userKey,  value: jsonEncode(result.user.toJson())),
      ]);

      return result.user;
    });
  }

  Future<void> logout() async {
    state = const AsyncLoading();

    final service = ref.read(authServiceProvider);
    final storage = ref.read(_storageProvider);

    await service.logout().catchError((_) {});

    await Future.wait([
      storage.delete(key: AppConstants.tokenKey),
      storage.delete(key: AppConstants.userKey),
    ]);

    state = const AsyncData(null);
  }
}
