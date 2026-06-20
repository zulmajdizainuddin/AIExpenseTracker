import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user      = ref.watch(authStateProvider).value;
    final dashboard = ref.watch(dashboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Hello, ${user?.name.split(' ').first ?? ''} 👋'),
        actions: [
          IconButton(
            icon: const Icon(Icons.document_scanner_outlined),
            tooltip: 'Scan Receipt',
            onPressed: () => context.push('/receipt/scan'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(dashboardProvider.future),
        child: dashboard.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error:   (e, _) => Center(child: Text(e.toString())),
          data:    (data) => _DashboardContent(data: data),
        ),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({required this.data});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final current  = data['current_month'] as Map<String, dynamic>;
    final previous = data['previous_month'] as Map<String, dynamic>;
    final breakdown = data['category_breakdown'] as List? ?? [];

    final total    = double.tryParse(current['total'].toString()) ?? 0;
    final prevTotal = double.tryParse(previous['total'].toString()) ?? 0;
    final currency = NumberFormat.currency(locale: 'en_MY', symbol: 'RM ');

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Monthly summary card
        Card(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('This Month', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                Text(
                  currency.format(total),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'vs ${currency.format(prevTotal)} last month',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Category breakdown
        Text('Spending by Category', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        if (breakdown.isEmpty)
          const Center(child: Padding(
            padding: EdgeInsets.all(32),
            child: Text('No spending data yet.'),
          ))
        else
          ...breakdown.map((item) {
            final cat   = item['category'] as Map<String, dynamic>? ?? {};
            final catTotal = double.tryParse(item['total'].toString()) ?? 0;
            final percent = total > 0 ? catTotal / total : 0.0;
            final color = _parseColor(cat['color']?.toString() ?? '#6366f1');

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(cat['name']?.toString() ?? 'Other'),
                      Text(currency.format(catTotal), style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percent.clamp(0.0, 1.0),
                      backgroundColor: color.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation(color),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  Color _parseColor(String hex) {
    final c = hex.replaceAll('#', '');
    return Color(int.parse('FF$c', radix: 16));
  }
}
