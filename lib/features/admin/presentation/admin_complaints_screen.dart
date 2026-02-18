import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/color_scheme.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/widgets/shimmer_widgets.dart';
import '../../../../providers/app_state_provider.dart';

class AdminComplaintsScreen extends ConsumerWidget {
  const AdminComplaintsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final complaintsAsync = ref.watch(complaintsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Complaints'), elevation: 0),
      body: complaintsAsync.when(
        loading: () => const ShimmerList(height: 140),
        error: (e, _) => ErrorStateWidget(
          message: 'Failed to load complaints: $e',
          onRetry: () => ref.invalidate(complaintsProvider),
        ),
        data: (complaints) {
          if (complaints.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.assignment_turned_in_rounded,
              title: 'No Complaints',
              subtitle:
                  'Everything is running smoothly! No tenant complaints at the moment.',
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.refresh(complaintsProvider.future),
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: complaints.length,
              itemBuilder: (context, index) {
                final complaint = complaints[index];
                final timeFormat = DateFormat('MMM dd, hh:mm a');

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    complaint.tenantName,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Office: ${complaint.officeNumber}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: (complaint.type == 'general'
                                        ? AppColors.primary
                                        : AppColors.accent)
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                complaint.type == 'general'
                                    ? 'GENERAL'
                                    : 'PERSONAL',
                                style: TextStyle(
                                  color: complaint.type == 'general'
                                      ? AppColors.primary
                                      : AppColors.accent,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: complaint.status == 'Open'
                                    ? AppColors.warning.withValues(alpha: 0.1)
                                    : AppColors.success.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                complaint.status,
                                style: TextStyle(
                                  color: complaint.status == 'Open'
                                      ? AppColors.warning
                                      : AppColors.success,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          complaint.description,
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          timeFormat.format(complaint.timestamp),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (complaint.status == 'Open') ...[
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () async {
                              await ref
                                  .read(complaintsProvider.notifier)
                                  .markResolved(complaint.id);
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Complaint marked as resolved'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.success,
                              minimumSize: const Size(double.infinity, 40),
                            ),
                            child: const Text('Mark as Resolved'),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
