import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../models/expense_model.dart';
import '../providers/expense_provider.dart';

class ExpenseListScreen extends ConsumerWidget {
  const ExpenseListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenses = ref.watch(expenseListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => showSearch(context: context, delegate: _ExpenseSearchDelegate(ref)),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/expenses/new'),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      body: expenses.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Failed to load expenses', style: Theme.of(context).textTheme.bodyLarge),
              TextButton(
                onPressed: () => ref.read(expenseListProvider.notifier).refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (items) => items.isEmpty
            ? const Center(child: Text('No expenses yet. Tap + to add one.'))
            : RefreshIndicator(
                onRefresh: () => ref.read(expenseListProvider.notifier).refresh(),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) => _ExpenseCard(expense: items[i]),
                ),
              ),
      ),
    );
  }
}

class _ExpenseCard extends ConsumerWidget {
  const _ExpenseCard({required this.expense});
  final ExpenseModel expense;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = _parseColor(expense.category?.color ?? '#6366f1');
    final formatted = NumberFormat.currency(locale: 'en_MY', symbol: 'RM ').format(expense.amount);
    final date = DateFormat('dd MMM yyyy').format(expense.transactionDate);

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(Icons.receipt_long, color: color),
        ),
        title: Text(expense.title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('${expense.category?.name ?? 'Uncategorized'} • $date'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(formatted, style: TextStyle(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.bold)),
            PopupMenuButton(
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit',   child: Text('Edit')),
                const PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
              onSelected: (val) async {
                if (val == 'edit') {
                  context.push('/expenses/${expense.id}/edit');
                } else {
                  final confirmed = await _confirmDelete(context);
                  if (confirmed == true) {
                    ref.read(expenseListProvider.notifier).deleteExpense(expense.id);
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) => showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Delete Expense'),
          content: Text('Delete "${expense.title}"?'),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(true),  child: const Text('Delete')),
          ],
        ),
      );

  Color _parseColor(String hex) {
    final c = hex.replaceAll('#', '');
    return Color(int.parse('FF$c', radix: 16));
  }
}

class _ExpenseSearchDelegate extends SearchDelegate<String> {
  _ExpenseSearchDelegate(this.ref);
  final WidgetRef ref;

  @override
  List<Widget> buildActions(BuildContext context) => [
        IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
      ];

  @override
  Widget buildLeading(BuildContext context) =>
      IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => close(context, ''));

  @override
  Widget buildResults(BuildContext context) => const SizedBox.shrink();

  @override
  Widget buildSuggestions(BuildContext context) => const SizedBox.shrink();
}
