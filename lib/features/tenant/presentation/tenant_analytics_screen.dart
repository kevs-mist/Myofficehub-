import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/color_scheme.dart';
import '../../../../core/ui/app_layout.dart';
import '../../../../core/widgets/app_background.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/shimmer_widgets.dart';
import '../../admin/presentation/widgets/revenue_chart.dart';
import 'providers/tenant_analytics_provider.dart';

class TenantAnalyticsScreen extends ConsumerWidget {
  const TenantAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(tenantAnalyticsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Analytics'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: AppBackground(
        child: analyticsAsync.when(
          data: (state) => SingleChildScrollView(
            padding: AppLayout.screenInsets,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(title: '💰 Maintenance Trends'),
                AppLayout.v16,
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: RevenueChart(
                      trends: state.monthlyPayments,
                      height: 180,
                    ),
                  ),
                ).animate().fadeIn().slideY(begin: 0.1, end: 0),

                AppLayout.v32,
                const SectionHeader(title: '📊 Key Performance'),
                AppLayout.v16,
                Row(
                  children: [
                    Expanded(
                      child: _MetricTile(
                        label: 'Total Paid',
                        value: '₹${state.totalSpent.toStringAsFixed(0)}',
                        icon: Icons.payments_outlined,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _MetricTile(
                        label: 'Active Issues',
                        value: state.activeComplaints.toString(),
                        icon: Icons.error_outline_rounded,
                        color: AppColors.highlight,
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 200.ms),

                AppLayout.v32,
                const SectionHeader(title: '🛠️ Complaint Status'),
                AppLayout.v16,
                ...state.complaintStats.entries
                    .map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _StatusRow(label: entry.key, count: entry.value),
                      );
                    })
                    .toList()
                    .animate()
                    .fadeIn(delay: 400.ms),

                const SizedBox(height: 100),
              ],
            ),
          ),
          loading: () => const Padding(
            padding: AppLayout.screenInsets,
            child: Column(
              children: [
                ShimmerCard(height: 200),
                SizedBox(height: 20),
                ShimmerCard(height: 100),
              ],
            ),
          ),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: color.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: color.withValues(alpha: 0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 16),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final String label;
  final int count;

  const _StatusRow({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    final color = label == 'Resolved'
        ? AppColors.success
        : label == 'Open'
        ? AppColors.highlight
        : AppColors.accent;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.textSecondary.withValues(alpha: 0.1),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 16),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          Text(
            count.toString(),
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 18,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
