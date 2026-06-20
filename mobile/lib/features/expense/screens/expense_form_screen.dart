import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';

class ExpenseFormScreen extends ConsumerStatefulWidget {
  const ExpenseFormScreen({super.key, this.expenseId});
  final int? expenseId;

  @override
  ConsumerState<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends ConsumerState<ExpenseFormScreen> {
  final _formKey    = GlobalKey<FormState>();
  final _titleCtrl  = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _noteCtrl   = TextEditingController();

  int? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();

  bool get _isEditing => widget.expenseId != null;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category.')),
      );
      return;
    }

    await ref.read(createExpenseProvider.notifier).create(
          categoryId:      _selectedCategoryId!,
          title:           _titleCtrl.text.trim(),
          amount:          double.parse(_amountCtrl.text),
          transactionDate: DateFormat('yyyy-MM-dd').format(_selectedDate),
          note:            _noteCtrl.text.isNotEmpty ? _noteCtrl.text.trim() : null,
        );

    final state = ref.read(createExpenseProvider);
    if (!mounted) return;

    if (state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save expense.')),
      );
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);
    final isLoading  = ref.watch(createExpenseProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Expense' : 'New Expense'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Title is required.' : null,
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
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Amount is required.';
                  if (double.tryParse(v) == null) return 'Enter a valid amount.';
                  if (double.parse(v) <= 0) return 'Amount must be greater than 0.';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              categories.when(
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const Text('Could not load categories.'),
                data: (cats) => DropdownButtonFormField<int>(
                  value: _selectedCategoryId,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: cats.map((c) => DropdownMenuItem(
                        value: c.id,
                        child: Text(c.name),
                      )).toList(),
                  onChanged: (v) => setState(() => _selectedCategoryId = v),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                  side: BorderSide(color: Theme.of(context).colorScheme.outline),
                ),
                title: const Text('Date'),
                subtitle: Text(DateFormat('dd MMMM yyyy').format(_selectedDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _noteCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Note (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: isLoading ? null : _submit,
                  child: isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(_isEditing ? 'Update Expense' : 'Save Expense'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
