import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/expense_repository.dart';
import '../models/expense_model.dart';

final categoriesProvider = FutureProvider<List<CategoryModel>>((ref) {
  return ref.watch(expenseRepositoryProvider).getCategories();
});

final expenseListProvider = AsyncNotifierProvider<ExpenseListNotifier, List<ExpenseModel>>(
  ExpenseListNotifier.new,
);

class ExpenseListNotifier extends AsyncNotifier<List<ExpenseModel>> {
  @override
  Future<List<ExpenseModel>> build() async {
    return ref.watch(expenseRepositoryProvider).getExpenses();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(expenseRepositoryProvider).getExpenses());
  }

  Future<void> deleteExpense(int id) async {
    await ref.read(expenseRepositoryProvider).deleteExpense(id);
    state = AsyncData(
      state.value!.where((e) => e.id != id).toList(),
    );
  }
}

final createExpenseProvider = AsyncNotifierProvider<CreateExpenseNotifier, void>(
  CreateExpenseNotifier.new,
);

class CreateExpenseNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> create({
    required int categoryId,
    required String title,
    required double amount,
    required String transactionDate,
    String? note,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(expenseRepositoryProvider).createExpense(
            categoryId:      categoryId,
            title:           title,
            amount:          amount,
            transactionDate: transactionDate,
            note:            note,
          );
      ref.invalidate(expenseListProvider);
    });
  }
}
