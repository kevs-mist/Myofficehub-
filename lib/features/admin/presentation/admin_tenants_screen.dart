import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/color_scheme.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/widgets/shimmer_widgets.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../providers/app_state_provider.dart';
import '../../../../models/tenant_model.dart';

class AdminTenantsScreen extends ConsumerWidget {
  const AdminTenantsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tenantsAsync = ref.watch(tenantsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Tenants'), elevation: 0),
      body: tenantsAsync.when(
        loading: () => const ShimmerList(height: 80),
        error: (e, _) => ErrorStateWidget(
          message: 'Failed to load tenants: $e',
          onRetry: () => ref.invalidate(tenantsProvider),
        ),
        data: (tenants) {
          if (tenants.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.people_outline_rounded,
              title: 'No Tenants Yet',
              subtitle:
                  'Start by adding your first tenant to manage their workspace.',
              actionLabel: 'Add Tenant',
              onAction: () => _showAddTenantDialog(context, ref),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.refresh(tenantsProvider.future),
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: tenants.length,
              itemBuilder: (context, index) {
                final tenant = tenants[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    onTap: () => _showTenantDetails(context, tenant),
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      child: Text(
                        tenant.name.isEmpty ? '?' : tenant.name[0],
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(tenant.name),
                    subtitle: Text(
                      'Office: ${tenant.officeNumber} • ${tenant.employeeCount} employees',
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: tenant.status == 'Active'
                            ? AppColors.success.withValues(alpha: 0.1)
                            : AppColors.warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        tenant.status,
                        style: TextStyle(
                          color: tenant.status == 'Active'
                              ? AppColors.success
                              : AppColors.warning,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAddTenantDialog(context, ref);
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text('Add Tenant'),
      ),
    );
  }

  void _showTenantDetails(BuildContext context, TenantModel tenant) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tenant.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailItem(label: 'Office Number', value: tenant.officeNumber),
            const SizedBox(height: 8),
            _DetailItem(
              label: 'Employee Count',
              value: tenant.employeeCount.toString(),
            ),
            const SizedBox(height: 8),
            _DetailItem(
              label: 'Vehicle Count',
              value: tenant.vehicleCount.toString(),
            ),
            const SizedBox(height: 8),
            _DetailItem(
              label: 'Status',
              value: tenant.status,
              valueColor: tenant.status == 'Active'
                  ? AppColors.success
                  : AppColors.warning,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Manage ${tenant.name} - Coming Soon')),
              );
            },
            child: const Text('Manage'),
          ),
        ],
      ),
    );
  }

  void _showAddTenantDialog(BuildContext context, WidgetRef ref) {
    final emailController = TextEditingController();
    final nameController = TextEditingController();
    final officeController = TextEditingController();
    final employeeController = TextEditingController(text: '0');
    final vehicleController = TextEditingController(text: '0');
    final formKey = GlobalKey<FormState>();

    int tabIndex = 0;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Add Tenant'),
            content: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 420,
                maxHeight: MediaQuery.of(context).size.height * 0.7,
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SegmentedButton<int>(
                        segments: const [
                          ButtonSegment(value: 0, label: Text('Invite')),
                          ButtonSegment(value: 1, label: Text('Manual Add')),
                        ],
                        selected: {tabIndex},
                        onSelectionChanged: (value) {
                          setState(() {
                            tabIndex = value.first;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      if (tabIndex == 0)
                        TextFormField(
                          controller: emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email Address',
                            hintText: 'tenant@company.com',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter an email';
                            }
                            if (!value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        )
                      else
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextFormField(
                              controller: nameController,
                              decoration: const InputDecoration(
                                labelText: 'Company Name',
                                prefixIcon: Icon(Icons.business_outlined),
                              ),
                              validator: (value) =>
                                  value?.isEmpty ?? true ? 'Required' : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: officeController,
                              decoration: const InputDecoration(
                                labelText: 'Office Number',
                                prefixIcon: Icon(Icons.numbers_outlined),
                              ),
                              validator: (value) =>
                                  value?.isEmpty ?? true ? 'Required' : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: emailController,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                prefixIcon: Icon(Icons.email_outlined),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                if (!value.contains('@')) {
                                  return 'Invalid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: employeeController,
                              decoration: const InputDecoration(
                                labelText: 'Employee Count',
                                prefixIcon: Icon(Icons.people_outlined),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: vehicleController,
                              decoration: const InputDecoration(
                                labelText: 'Vehicle Count',
                                prefixIcon: Icon(Icons.directions_car_outlined),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (!(formKey.currentState?.validate() ?? false)) return;

                  HapticService.medium();
                  final tenants = ref.read(tenantsProvider.notifier);
                  if (tabIndex == 0) {
                    final email = emailController.text.trim();
                    await tenants.inviteTenant(email);
                    if (!context.mounted) return;
                    Navigator.pop(dialogContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Invitation sent to $email'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  } else {
                    final name = nameController.text.trim();
                    final office = officeController.text.trim();
                    final email = emailController.text.trim();
                    final employees =
                        int.tryParse(employeeController.text) ?? 0;
                    final vehicles = int.tryParse(vehicleController.text) ?? 0;

                    await tenants.addTenantManual(
                      name: name,
                      officeNumber: office,
                      email: email,
                      employeeCount: employees,
                      vehicleCount: vehicles,
                    );
                    if (!context.mounted) return;
                    Navigator.pop(dialogContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Tenant added: $name'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                },
                child: Text(tabIndex == 0 ? 'Send Invitation' : 'Add Tenant'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailItem({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
