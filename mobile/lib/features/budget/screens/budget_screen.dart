import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
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
        ],
      ),
      body: Column(
        children: [
          // Month selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => setState(() {
                    _month--;
                    if (_month < 1) { _month = 12; _year--; }
                  }),
                ),
                Text(
                  DateFormat('MMMM yyyy').format(DateTime(_year, _month)),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => setState(() {
                    _month++;
                    if (_month > 12) { _month = 1; _year++; }
                  }),
                ),
              ],
            ),
          ),
          Expanded(
            child: budgets.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error:   (e, _) => Center(child: Text(e.toString())),
              data:    (items) => items.isEmpty
                  ? const Center(child: Text('No budgets set. Tap + to add one.'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: items.length,
                      itemBuilder: (_, i) => _BudgetCard(summary: items[i], currency: currency),
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

class _BudgetCard extends StatelessWidget {
  const _BudgetCard({required this.summary, required this.currency});
  final BudgetSummary summary;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    final color = _parseColor(summary.categoryColor);
    final isOver = summary.percent > 100;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(summary.categoryName, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  '${summary.percent.toStringAsFixed(1)}%',
                  style: TextStyle(color: isOver ? Colors.red : null),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (summary.percent / 100).clamp(0.0, 1.0),
                backgroundColor: color.withOpacity(0.15),
                valueColor: AlwaysStoppedAnimation(isOver ? Colors.red : color),
                minHeight: 10,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Spent: ${currency.format(summary.spent)}', style: Theme.of(context).textTheme.bodySmall),
                Text('Budget: ${currency.format(summary.budgetAmount)}', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _parseColor(String hex) {
    final c = hex.replaceAll('#', '');
    return Color(int.parse('FF$c', radix: 16));
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
      padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Set Budget', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          categories.when(
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const Text('Could not load categories.'),
            data: (cats) => DropdownButtonFormField<int>(
              decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
              items: cats.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
              onChanged: (v) => setState(() => _categoryId = v),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _amountCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Amount (RM)',
              border: OutlineInputBorder(),
              prefixText: 'RM ',
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: isLoading || _categoryId == null ? null : _save,
              child: const Text('Save Budget'),
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
