import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/color_scheme.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/widgets/shimmer_widgets.dart';
import '../../../../providers/tenant_profile_provider.dart';
import '../../../../providers/app_state_provider.dart';

class TenantPaymentsScreen extends ConsumerStatefulWidget {
  const TenantPaymentsScreen({super.key});

  @override
  ConsumerState<TenantPaymentsScreen> createState() =>
      _TenantPaymentsScreenState();
}

class _TenantPaymentsScreenState extends ConsumerState<TenantPaymentsScreen> {
  @override
  Widget build(BuildContext context) {
    final paymentsAsync = ref.watch(paymentsProvider);
    final profileAsync = ref.watch(tenantProfileProvider);
    final adminAsync = ref.watch(adminProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: profileAsync.when(
          data: (profile) => Text(profile?.companyName ?? 'Payments'),
          loading: () => const Text('Payments'),
          error: (_, _) => const Text('Payments'),
        ),
      ),
      body: paymentsAsync.when(
        loading: () => const ShimmerList(height: 180),
        error: (e, _) => ErrorStateWidget(
          message: 'Failed to load payments: $e',
          onRetry: () => ref.invalidate(paymentsProvider),
        ),
        data: (payments) {
          final lateFee = adminAsync.asData?.value.lateFee ?? 0;
          final pendingPayments = payments
              .where((p) => p.status != 'Paid')
              .toList();
          final historyPayments = payments
              .where((p) => p.status == 'Paid')
              .toList();
          final totalDue = pendingPayments.fold<double>(0, (sum, p) {
            final isOverdue =
                p.status == 'Overdue' && p.dueDate.isBefore(DateTime.now());
            return sum + p.amount + (isOverdue ? lateFee : 0);
          });

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Current Month Bill
                if (pendingPayments.isNotEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                DateFormat('MMMM yyyy').format(DateTime.now()),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.error.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  pendingPayments.any(
                                        (p) => p.status == 'Overdue',
                                      )
                                      ? 'Overdue'
                                      : 'Pending',
                                  style: TextStyle(
                                    color:
                                        pendingPayments.any(
                                          (p) => p.status == 'Overdue',
                                        )
                                        ? AppColors.error
                                        : AppColors.warning,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 32),
                          ...pendingPayments.map(
                            (p) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _FeeRow(
                                label: p.type,
                                amount: p.amount,
                                isHighlighted: p.status == 'Overdue',
                              ),
                            ),
                          ),
                          const Divider(height: 32),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total Amount',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '₹${totalDue.toStringAsFixed(0)}',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      color: AppColors.error,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () =>
                                _showPaymentDialog(context, totalDue),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              backgroundColor: AppColors.primary,
                            ),
                            child: const Text('Pay Now'),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Center(
                            child: Icon(
                              Icons.check_circle_outline,
                              color: AppColors.success,
                              size: 48,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Center(
                            child: Text(
                              'All Dues Cleared!',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Center(
                            child: Text(
                              'You have no pending payments for this month.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 24),

                // Payment History
                const Text(
                  'Payment History',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                if (historyPayments.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text('No payment history found'),
                    ),
                  )
                else
                  ...historyPayments.map(
                    (p) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _PaymentHistoryCard(
                        month: DateFormat('MMMM yyyy').format(p.dueDate),
                        amount: p.amount,
                        status: p.status,
                        date: DateFormat('MMM d, yyyy').format(p.dueDate),
                        isPaid: p.status == 'Paid',
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showPaymentDialog(BuildContext context, double totalAmount) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Payment Method'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PaymentMethodTile(
              icon: Icons.account_balance,
              title: 'UPI',
              onTap: () {
                Navigator.pop(context);
                _processPayment('UPI', totalAmount);
              },
            ),
            _PaymentMethodTile(
              icon: Icons.credit_card,
              title: 'Card',
              onTap: () {
                Navigator.pop(context);
                _processPayment('Card', totalAmount);
              },
            ),
            _PaymentMethodTile(
              icon: Icons.account_balance_wallet,
              title: 'Net Banking',
              onTap: () {
                Navigator.pop(context);
                _processPayment('Net Banking', totalAmount);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _processPayment(String method, double totalAmount) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: AppColors.success, size: 32),
              SizedBox(width: 12),
              Text('Payment Successful!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Payment Method: $method'),
              const SizedBox(height: 8),
              Text('Amount: ₹${totalAmount.toStringAsFixed(0)}'),
              const SizedBox(height: 8),
              Text(
                'Transaction ID: TXN${DateTime.now().millisecondsSinceEpoch}',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Done'),
            ),
          ],
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment made via $method'),
          backgroundColor: AppColors.success,
        ),
      );
    });
  }
}

class _PaymentMethodTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _PaymentMethodTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      onTap: onTap,
    );
  }
}

class _FeeRow extends StatelessWidget {
  final String label;
  final double amount;
  final bool isHighlighted;

  const _FeeRow({
    required this.label,
    required this.amount,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: isHighlighted ? AppColors.error : AppColors.textPrimary,
          ),
        ),
        Text(
          '₹${amount.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isHighlighted ? AppColors.error : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _PaymentHistoryCard extends StatelessWidget {
  final String month;
  final double amount;
  final String status;
  final String date;
  final bool isPaid;

  const _PaymentHistoryCard({
    required this.month,
    required this.amount,
    required this.status,
    required this.date,
    required this.isPaid,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (isPaid ? AppColors.success : AppColors.error).withValues(
              alpha: 0.1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isPaid ? Icons.check_circle : Icons.pending,
            color: isPaid ? AppColors.success : AppColors.error,
          ),
        ),
        title: Text(month, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(date),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '₹${amount.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: (isPaid ? AppColors.success : AppColors.error)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: isPaid ? AppColors.success : AppColors.error,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
