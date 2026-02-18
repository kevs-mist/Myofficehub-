import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/color_scheme.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/widgets/shimmer_widgets.dart';
import '../../../../models/staff_model.dart';
import '../../../../providers/app_state_provider.dart';

class AdminOfficeHelpScreen extends ConsumerWidget {
  const AdminOfficeHelpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final staffAsync = ref.watch(staffProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Office Help'), elevation: 0),
      body: staffAsync.when(
        loading: () => const ShimmerList(height: 80),
        error: (e, _) => ErrorStateWidget(
          message: 'Failed to load office help: $e',
          onRetry: () => ref.invalidate(staffProvider),
        ),
        data: (staff) {
          final helpers = staff.where((s) => s.role == 'help').toList();
          if (helpers.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.cleaning_services_rounded,
              title: 'No Office Help',
              subtitle: 'No office help staff have been added yet.',
            );
          }

          final byOffice = <String, List<StaffModel>>{};
          for (final h in helpers) {
            for (final office in h.assignedOffices) {
              byOffice.putIfAbsent(office, () => []).add(h);
            }
          }

          final offices = byOffice.keys.toList()..sort();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: offices.length,
            itemBuilder: (context, index) {
              final office = offices[index];
              final list = byOffice[office] ?? const <StaffModel>[];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                    child: const Icon(
                      Icons.cleaning_services_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  title: Text('Office $office'),
                  subtitle: Text('${list.length} helpers'),
                  children: [
                    for (final h in list)
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              AppColors.accent.withValues(alpha: 0.12),
                          child: Text(
                            h.name.isEmpty ? '?' : h.name[0],
                            style: const TextStyle(
                              color: AppColors.accent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(h.name),
                        subtitle: const Text('Office Help'),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
