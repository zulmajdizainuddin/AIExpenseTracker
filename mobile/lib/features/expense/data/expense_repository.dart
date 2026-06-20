import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../models/expense_model.dart';

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return ExpenseRepository(ref.watch(dioClientProvider));
});

class ExpenseRepository {
  ExpenseRepository(this._client);
  final DioClient _client;

  Future<List<ExpenseModel>> getExpenses({
    int? categoryId,
    String? from,
    String? to,
    String? search,
    int page = 1,
  }) async {
    try {
      final res = await _client.get('/expenses', queryParameters: {
        if (categoryId != null) 'category_id': categoryId,
        if (from != null) 'from': from,
        if (to != null) 'to': to,
        if (search != null && search.isNotEmpty) 'search': search,
        'page': page,
      });
      final items = res.data['data']['data'] as List;
      return items.map((e) => ExpenseModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<ExpenseModel> createExpense({
    required int categoryId,
    required String title,
    required double amount,
    required String transactionDate,
    String? note,
  }) async {
    try {
      final res = await _client.post('/expenses', data: {
        'category_id':      categoryId,
        'title':            title,
        'amount':           amount,
        'transaction_date': transactionDate,
        if (note != null) 'note': note,
      });
      return ExpenseModel.fromJson(res.data['data']);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<ExpenseModel> updateExpense(int id, Map<String, dynamic> data) async {
    try {
      final res = await _client.put('/expenses/$id', data: data);
      return ExpenseModel.fromJson(res.data['data']);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<void> deleteExpense(int id) async {
    try {
      await _client.delete('/expenses/$id');
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<List<CategoryModel>> getCategories() async {
    try {
      final res = await _client.get('/categories');
      final items = res.data['data'] as List;
      return items.map((e) => CategoryModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
