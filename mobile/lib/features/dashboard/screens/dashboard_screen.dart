import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/gradient_card.dart';
import '../../../core/widgets/section_header.dart';
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
          const SizedBox(width: AppSpacing.xs),
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
    final current   = data['current_month'] as Map<String, dynamic>;
    final previous  = data['previous_month'] as Map<String, dynamic>;
    final breakdown = (data['category_breakdown'] as List? ?? []).cast<Map<String, dynamic>>();
    final trend     = (data['weekly_trend'] as List? ?? []).cast<Map<String, dynamic>>();

    final total     = double.tryParse(current['total'].toString()) ?? 0;
    final prevTotal = double.tryParse(previous['total'].toString()) ?? 0;
    final average   = double.tryParse(current['average'].toString()) ?? 0;
    final count     = current['count'] as int? ?? 0;
    final currency  = NumberFormat.currency(locale: 'en_MY', symbol: 'RM ');

    final isExpanded = context.isExpanded;

    final heroAndKpis = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _HeroCard(total: total, prevTotal: prevTotal, currency: currency),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(child: _StatTile(label: 'Transactions', value: '$count', icon: Icons.receipt_long_outlined)),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: _StatTile(label: 'Avg / transaction', value: currency.format(average), icon: Icons.trending_up_rounded)),
          ],
        ),
      ],
    );

    final trendSection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader('This Week'),
        const SizedBox(height: AppSpacing.md),
        _WeeklyTrendChart(trend: trend, currency: currency),
      ],
    );

    final breakdownSection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader('Spending by Category'),
        const SizedBox(height: AppSpacing.md),
        breakdown.isEmpty
            ? const _NoSpendingYet()
            : _CategoryBreakdownList(breakdown: breakdown, total: total, currency: currency),
      ],
    );

    return SingleChildScrollView(
      padding: EdgeInsets.all(context.contentPadding),
      child: ContentWidthLimiter(
        child: isExpanded
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  heroAndKpis,
                  const SizedBox(height: AppSpacing.xl),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: trendSection),
                        const SizedBox(width: AppSpacing.xl),
                        Expanded(child: breakdownSection),
                      ],
                    ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  heroAndKpis,
                  const SizedBox(height: AppSpacing.xl),
                  trendSection,
                  const SizedBox(height: AppSpacing.xl),
                  breakdownSection,
                ],
              ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.total, required this.prevTotal, required this.currency});
  final double total;
  final double prevTotal;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    final delta = prevTotal > 0 ? ((total - prevTotal) / prevTotal) * 100 : 0.0;
    final isUp = delta > 0;
    final hasComparison = prevTotal > 0;

    return GradientCard(
      gradient: AppGradients.brand,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This Month',
            style: TextStyle(color: Colors.white.withOpacity(0.85), fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            currency.format(total),
            style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppSpacing.md),
          if (hasComparison)
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(isUp ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded, size: 14, color: Colors.white),
                      const SizedBox(width: 2),
                      Text(
                        '${delta.abs().toStringAsFixed(1)}%',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'vs ${currency.format(prevTotal)} last month',
                    style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            )
          else
            Text(
              'No data from last month to compare',
              style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12),
            ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value, required this.icon});
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: scheme.primary),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _WeeklyTrendChart extends StatelessWidget {
  const _WeeklyTrendChart({required this.trend, required this.currency});
  final List<Map<String, dynamic>> trend;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (trend.isEmpty) {
      return Container(
        height: 180,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Text('No expenses this week yet', style: TextStyle(color: scheme.onSurfaceVariant)),
      );
    }

    final spots = <FlSpot>[];
    final dayLabels = <String>[];
    for (var i = 0; i < trend.length; i++) {
      final date = DateTime.tryParse(trend[i]['date'].toString());
      final total = double.tryParse(trend[i]['total'].toString()) ?? 0;
      spots.add(FlSpot(i.toDouble(), total));
      dayLabels.add(date != null ? DateFormat('E').format(date) : '');
    }
    final maxY = spots.map((s) => s.y).fold<double>(0, (a, b) => b > a ? b : a);

    return Container(
      height: 200,
      padding: const EdgeInsets.fromLTRB(AppSpacing.sm, AppSpacing.lg, AppSpacing.lg, AppSpacing.sm),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: maxY <= 0 ? 10 : maxY * 1.25,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY <= 0 ? 5 : (maxY * 1.25) / 3,
            getDrawingHorizontalLine: (_) => FlLine(color: scheme.outlineVariant.withOpacity(0.4), strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= dayLabels.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      dayLabels[i],
                      style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant),
                    ),
                  );
                },
              ),
            ),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => scheme.inverseSurface,
              getTooltipItems: (spots) => spots.map((s) {
                return LineTooltipItem(
                  currency.format(s.y),
                  TextStyle(color: scheme.onInverseSurface, fontWeight: FontWeight.w700, fontSize: 12),
                );
              }).toList(),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.25,
              color: scheme.primary,
              barWidth: 3,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                  radius: 4,
                  color: scheme.primary,
                  strokeWidth: 2,
                  strokeColor: scheme.surfaceContainerLow,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [scheme.primary.withOpacity(0.25), scheme.primary.withOpacity(0.0)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoSpendingYet extends StatelessWidget {
  const _NoSpendingYet();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      width: double.infinity,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Text(
        'No spending data yet this month.',
        textAlign: TextAlign.center,
        style: TextStyle(color: scheme.onSurfaceVariant),
      ),
    );
  }
}

/// Ranked horizontal bars — chosen over a pie/donut, which reads worse for
/// comparing close values. Bar length ranks against the top category; the
/// percentage-of-total is direct-labeled since color alone isn't reliable
/// once there are 4+ categories.
class _CategoryBreakdownList extends StatelessWidget {
  const _CategoryBreakdownList({required this.breakdown, required this.total, required this.currency});
  final List<Map<String, dynamic>> breakdown;
  final double total;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    final maxTotal = breakdown
        .map((e) => double.tryParse(e['total'].toString()) ?? 0)
        .fold<double>(0, (a, b) => b > a ? b : a);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        children: [
          for (var i = 0; i < breakdown.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.lg),
            _CategoryBar(
              index: i,
              row: breakdown[i],
              maxTotal: maxTotal,
              total: total,
              currency: currency,
            ),
          ],
        ],
      ),
    );
  }
}

class _CategoryBar extends StatelessWidget {
  const _CategoryBar({
    required this.index,
    required this.row,
    required this.maxTotal,
    required this.total,
    required this.currency,
  });

  final int index;
  final Map<String, dynamic> row;
  final double maxTotal;
  final double total;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final category = row['category'] as Map<String, dynamic>? ?? {};
    final catTotal = double.tryParse(row['total'].toString()) ?? 0;
    final name = category['name']?.toString() ?? 'Other';
    final color = _parseColor(category['color']?.toString(), fallbackIndex: index);
    final widthFraction = maxTotal > 0 ? (catTotal / maxTotal).clamp(0.0, 1.0) : 0.0;
    final percentOfTotal = total > 0 ? (catTotal / total) * 100 : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(name, style: const TextStyle(fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
            ),
            Text(
              currency.format(catTotal),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: AppSpacing.sm),
            SizedBox(
              width: 42,
              child: Text(
                '${percentOfTotal.toStringAsFixed(0)}%',
                textAlign: TextAlign.end,
                style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Stack(
          alignment: Alignment.centerLeft,
          children: [
            Container(
              height: 8,
              width: double.infinity,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: widthFraction,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutCubic,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _parseColor(String? hex, {required int fallbackIndex}) {
    if (hex == null || hex.isEmpty) return AppColors.categoricalAt(fallbackIndex);
    final c = hex.replaceAll('#', '');
    try {
      return Color(int.parse('FF$c', radix: 16));
    } catch (_) {
      return AppColors.categoricalAt(fallbackIndex);
    }
  }
}
