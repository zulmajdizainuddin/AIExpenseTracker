import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/empty_state.dart';
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
            onPressed: () => showSearch(context: context, delegate: _ExpenseSearchDelegate()),
          ),
          const SizedBox(width: AppSpacing.xs),
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
            ? const EmptyState(
                icon: Icons.receipt_long_outlined,
                title: 'No expenses yet',
                message: 'Tap the + button to add your first expense.',
              )
            : RefreshIndicator(
                onRefresh: () => ref.read(expenseListProvider.notifier).refresh(),
                child: _ExpenseGrid(items: items),
              ),
      ),
    );
  }
}

class _ExpenseGrid extends StatelessWidget {
  const _ExpenseGrid({required this.items});
  final List<ExpenseModel> items;

  @override
  Widget build(BuildContext context) {
    final columns = context.gridColumns;

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: context.maxContentWidth),
        child: columns == 1
            ? ListView.separated(
                padding: EdgeInsets.all(context.contentPadding),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, i) => _ExpenseCard(expense: items[i]),
              )
            : GridView.builder(
                padding: EdgeInsets.all(context.contentPadding),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisExtent: 84,
                  crossAxisSpacing: AppSpacing.md,
                  mainAxisSpacing: AppSpacing.md,
                ),
                itemCount: items.length,
                itemBuilder: (context, i) => _ExpenseCard(expense: items[i]),
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
    final scheme = Theme.of(context).colorScheme;
    final color = _parseColor(expense.category?.color);
    final formatted = NumberFormat.currency(locale: 'en_MY', symbol: 'RM ').format(expense.amount);
    final date = DateFormat('dd MMM yyyy').format(expense.transactionDate);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: () => context.push('/expenses/${expense.id}/edit'),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
                child: Icon(Icons.receipt_long_rounded, color: color),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.title,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${expense.category?.name ?? 'Uncategorized'} • $date',
                      style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                formatted,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
              ),
              PopupMenuButton(
                icon: Icon(Icons.more_vert, color: scheme.onSurfaceVariant),
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

  Color _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return AppColors.brand;
    final c = hex.replaceAll('#', '');
    try {
      return Color(int.parse('FF$c', radix: 16));
    } catch (_) {
      return AppColors.brand;
    }
  }
}

class _ExpenseSearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) => [
        IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
      ];

  @override
  Widget buildLeading(BuildContext context) =>
      IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => close(context, ''));

  @override
  Widget buildResults(BuildContext context) => _buildSearchResults(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildSearchResults(context);

  Widget _buildSearchResults(BuildContext context) {
    if (query.isEmpty) return const SizedBox.shrink();

    return Consumer(
      builder: (context, ref, _) {
        final results = ref.watch(searchExpensesProvider(query));

        return results.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Search failed: $e')),
          data: (expenses) => expenses.isEmpty
              ? const EmptyState(icon: Icons.search_off_rounded, title: 'No expenses found')
              : ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: expenses.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, i) => _ExpenseCard(expense: expenses[i]),
                ),
        );
      },
    );
  }
}
