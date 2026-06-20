import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../models/budget_model.dart';

final budgetProvider = FutureProvider.family<List<BudgetSummary>, ({int year, int month})>(
  (ref, period) async {
    final client = ref.watch(dioClientProvider);
    try {
      final res = await client.get('/budgets', queryParameters: {
        'year':  period.year,
        'month': period.month,
      });
      final items = res.data['data'] as List;
      return items.map((e) => BudgetSummary.fromJson(e)).toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  },
);

final createBudgetProvider = AsyncNotifierProvider<CreateBudgetNotifier, void>(
  CreateBudgetNotifier.new,
);

class CreateBudgetNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> save({
    required int categoryId,
    required double amount,
    required int month,
    required int year,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final client = ref.read(dioClientProvider);
      await client.post('/budgets', data: {
        'category_id': categoryId,
        'amount':      amount,
        'month':       month,
        'year':        year,
      });
      ref.invalidate(budgetProvider);
    });
  }
}
