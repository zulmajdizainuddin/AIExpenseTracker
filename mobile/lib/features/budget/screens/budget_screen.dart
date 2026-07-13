import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/empty_state.dart';
import '../models/budget_model.dart';
import '../providers/budget_provider.dart';
import '../../expense/providers/expense_provider.dart';

class BudgetScreen extends ConsumerStatefulWidget {
  const BudgetScreen({super.key});

  @override
  ConsumerState<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends ConsumerState<BudgetScreen> {
  late int _year;
  late int _month;

  @override
  void initState() {
    super.initState();
    _year  = DateTime.now().year;
    _month = DateTime.now().month;
  }

  @override
  Widget build(BuildContext context) {
    final period  = (year: _year, month: _month);
    final budgets = ref.watch(budgetProvider(period));
    final currency = NumberFormat.currency(locale: 'en_MY', symbol: 'RM ');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budgets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddBudgetSheet(context),
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: Column(
        children: [
          _MonthSelector(
            year: _year,
            month: _month,
            onPrevious: () => setState(() {
              _month--;
              if (_month < 1) { _month = 12; _year--; }
            }),
            onNext: () => setState(() {
              _month++;
              if (_month > 12) { _month = 1; _year++; }
            }),
          ),
          Expanded(
            child: budgets.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error:   (e, _) => Center(child: Text(e.toString())),
              data:    (items) => items.isEmpty
                  ? const EmptyState(
                      icon: Icons.account_balance_wallet_outlined,
                      title: 'No budgets set',
                      message: 'Tap + to set a budget for a category this month.',
                    )
                  : Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: context.maxContentWidth),
                        child: GridView.builder(
                          padding: EdgeInsets.all(context.contentPadding),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: context.gridColumns,
                            mainAxisExtent: 132,
                            crossAxisSpacing: AppSpacing.md,
                            mainAxisSpacing: AppSpacing.md,
                          ),
                          itemCount: items.length,
                          itemBuilder: (_, i) => _BudgetCard(summary: items[i], currency: currency),
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddBudgetSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _AddBudgetSheet(year: _year, month: _month),
    );
  }
}

class _MonthSelector extends StatelessWidget {
  const _MonthSelector({
    required this.year,
    required this.month,
    required this.onPrevious,
    required this.onNext,
  });

  final int year;
  final int month;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(icon: const Icon(Icons.chevron_left), onPressed: onPrevious),
            Text(
              DateFormat('MMMM yyyy').format(DateTime(year, month)),
              style: Theme.of(context).textTheme.titleSmall,
            ),
            IconButton(icon: const Icon(Icons.chevron_right), onPressed: onNext),
          ],
        ),
      ),
    );
  }
}

class _BudgetCard extends StatelessWidget {
  const _BudgetCard({required this.summary, required this.currency});
  final BudgetSummary summary;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final categoryColor = _parseColor(summary.categoryColor);
    final statusColor = switch (summary.percent) {
      > 100 => AppColors.statusCritical,
      >= 80 => AppColors.statusWarning,
      _     => AppColors.statusGood,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(width: 8, height: 8, decoration: BoxDecoration(color: categoryColor, shape: BoxShape.circle)),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    summary.categoryName,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Text(
                    '${summary.percent.toStringAsFixed(0)}%',
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.w700, fontSize: 12),
                  ),
                ),
              ],
            ),
            const Spacer(),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: LinearProgressIndicator(
                value: (summary.percent / 100).clamp(0.0, 1.0),
                backgroundColor: statusColor.withOpacity(0.12),
                valueColor: AlwaysStoppedAnimation(statusColor),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Flexible(
                  child: Text(
                    '${currency.format(summary.spent)} spent',
                    style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Flexible(
                  child: Text(
                    'of ${currency.format(summary.budgetAmount)}',
                    style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _parseColor(String hex) {
    final c = hex.replaceAll('#', '');
    try {
      return Color(int.parse('FF$c', radix: 16));
    } catch (_) {
      return AppColors.brand;
    }
  }
}

class _AddBudgetSheet extends ConsumerStatefulWidget {
  const _AddBudgetSheet({required this.year, required this.month});
  final int year, month;

  @override
  ConsumerState<_AddBudgetSheet> createState() => _AddBudgetSheetState();
}

class _AddBudgetSheetState extends ConsumerState<_AddBudgetSheet> {
  final _amountCtrl  = TextEditingController();
  int? _categoryId;

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);
    final isLoading  = ref.watch(createBudgetProvider).isLoading;

    return Padding(
      padding: EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.md, AppSpacing.xl, MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppSpacing.lg),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
          ),
          Text('Set Budget', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.lg),
          categories.when(
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const Text('Could not load categories.'),
            data: (cats) => DropdownButtonFormField<int>(
              decoration: const InputDecoration(labelText: 'Category'),
              items: cats.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
              onChanged: (v) => setState(() => _categoryId = v),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          TextFormField(
            controller: _amountCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Amount (RM)',
              prefixText: 'RM ',
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: isLoading || _categoryId == null ? null : _save,
              child: isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Save Budget'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    if (_categoryId == null) return;
    final amount = double.tryParse(_amountCtrl.text);
    if (amount == null || amount <= 0) return;

    await ref.read(createBudgetProvider.notifier).save(
          categoryId: _categoryId!,
          amount:     amount,
          month:      widget.month,
          year:       widget.year,
        );

    if (mounted) Navigator.pop(context);
  }
}
