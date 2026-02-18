import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/color_scheme.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/widgets/shimmer_widgets.dart';
import '../../../../providers/app_state_provider.dart';

class AdminSecurityPersonnelScreen extends ConsumerWidget {
  const AdminSecurityPersonnelScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final staffAsync = ref.watch(staffProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Security Personnel'), elevation: 0),
      body: staffAsync.when(
        loading: () => const ShimmerList(height: 80),
        error: (e, _) => ErrorStateWidget(
          message: 'Failed to load security staff: $e',
          onRetry: () => ref.invalidate(staffProvider),
        ),
        data: (staff) {
          final security = staff.where((s) => s.role == 'security').toList();
          if (security.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.shield_rounded,
              title: 'No Security Personnel',
              subtitle: 'No security personnel have been added yet.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: security.length,
            itemBuilder: (context, index) {
              final s = security[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.highlight.withValues(
                      alpha: 0.12,
                    ),
                    child: Text(
                      s.name.isEmpty ? '?' : s.name[0],
                      style: const TextStyle(
                        color: AppColors.highlight,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(s.name),
                  subtitle: Text(
                    s.assignedOffices.isEmpty
                        ? 'No offices assigned'
                        : 'Offices: ${s.assignedOffices.join(', ')}',
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(s.name),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Role: Security',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              s.assignedOffices.isEmpty
                                  ? 'No offices assigned'
                                  : 'Assigned to: ${s.assignedOffices.join(', ')}',
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
