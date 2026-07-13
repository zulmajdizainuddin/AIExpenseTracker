import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/errors/failure.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/responsive.dart';
import '../../receipt/models/receipt_model.dart';
import '../providers/expense_provider.dart';

class ExpenseFormScreen extends ConsumerStatefulWidget {
  const ExpenseFormScreen({super.key, this.expenseId, this.initialData});
  final int? expenseId;
  final AiReceiptData? initialData;

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
  Map<String, String> _fieldErrors = {};

  bool get _isEditing => widget.expenseId != null;

  @override
  void initState() {
    super.initState();
    final data = widget.initialData;
    if (data == null) return;

    if (data.merchantName != null) _titleCtrl.text = data.merchantName!;
    if (data.amount != null) _amountCtrl.text = data.amount!.toString();
    if (data.date != null) {
      _selectedDate = DateTime.tryParse(data.date!) ?? DateTime.now();
    }
  }

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

    setState(() => _fieldErrors = {});

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
      final error = state.error;
      if (error is ValidationFailure && (error.errors?.isNotEmpty ?? false)) {
        setState(() {
          _fieldErrors = error.errors!.map((field, messages) => MapEntry(field, messages.first));
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save expense.')),
        );
      }
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);
    final isLoading  = ref.watch(createExpenseProvider).isLoading;
    final scheme     = Theme.of(context).colorScheme;

    final suggestion = widget.initialData?.categorySuggestion;
    if (suggestion != null && _selectedCategoryId == null) {
      final cats = categories.valueOrNull;
      final match = cats?.where((c) => c.name.toLowerCase() == suggestion.toLowerCase());
      if (match != null && match.isNotEmpty) {
        final matchedId = match.first.id;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _selectedCategoryId == null) {
            setState(() => _selectedCategoryId = matchedId);
          }
        });
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Expense' : 'New Expense'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(context.contentPadding),
        child: ContentWidthLimiter(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  if (widget.initialData != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: scheme.primaryContainer.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.auto_awesome_rounded, size: 18, color: scheme.primary),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                'Pre-filled from your scanned receipt — review before saving.',
                                style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  TextFormField(
                    controller: _titleCtrl,
                    decoration: InputDecoration(
                      labelText: 'Title',
                      errorText: _fieldErrors['title'],
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Title is required.' : null,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TextFormField(
                    controller: _amountCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Amount (RM)',
                      prefixText: 'RM ',
                      errorText: _fieldErrors['amount'],
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Amount is required.';
                      if (double.tryParse(v) == null) return 'Enter a valid amount.';
                      if (double.parse(v) <= 0) return 'Amount must be greater than 0.';
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  categories.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (_, __) => const Text('Could not load categories.'),
                    data: (cats) => DropdownButtonFormField<int>(
                      value: _selectedCategoryId,
                      decoration: InputDecoration(
                        labelText: 'Category',
                        errorText: _fieldErrors['category_id'],
                      ),
                      items: cats.map((c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(c.name),
                          )).toList(),
                      onChanged: (v) => setState(() => _selectedCategoryId = v),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  InkWell(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    onTap: _pickDate,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHighest.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: _fieldErrors['transaction_date'] != null
                            ? Border.all(color: scheme.error, width: 1.5)
                            : null,
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today_rounded, size: 18, color: scheme.onSurfaceVariant),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Text(
                              DateFormat('dd MMMM yyyy').format(_selectedDate),
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          Icon(Icons.arrow_drop_down_rounded, color: scheme.onSurfaceVariant),
                        ],
                      ),
                    ),
                  ),
                  if (_fieldErrors['transaction_date'] != null)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.xs, left: AppSpacing.md),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _fieldErrors['transaction_date']!,
                          style: TextStyle(color: scheme.error, fontSize: 12),
                        ),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.lg),
                  TextFormField(
                    controller: _noteCtrl,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Note (optional)',
                      errorText: _fieldErrors['note'],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: isLoading ? null : _submit,
                      child: isLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text(_isEditing ? 'Update Expense' : 'Save Expense'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
