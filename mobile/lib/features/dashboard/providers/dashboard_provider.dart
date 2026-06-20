import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';

final dashboardProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final client = ref.watch(dioClientProvider);
  try {
    final res = await client.get('/dashboard');
    return Map<String, dynamic>.from(res.data['data']);
  } on DioException catch (e) {
    throw mapDioError(e);
  }
});
