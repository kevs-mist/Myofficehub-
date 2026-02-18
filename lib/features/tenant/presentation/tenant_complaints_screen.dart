import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/color_scheme.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/widgets/shimmer_widgets.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../providers/app_state_provider.dart';
import '../../../../providers/tenant_profile_provider.dart';

class TenantComplaintsScreen extends ConsumerStatefulWidget {
  const TenantComplaintsScreen({super.key});

  @override
  ConsumerState<TenantComplaintsScreen> createState() =>
      _TenantComplaintsScreenState();
}

class _TenantComplaintsScreenState
    extends ConsumerState<TenantComplaintsScreen> {
  final _complaintController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _selectedCategory = 'Maintenance';
  String _selectedComplaintType = 'personal';

  @override
  void dispose() {
    _complaintController.dispose();
    super.dispose();
  }

  Future<void> _submitComplaint() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    HapticService.medium();
    final api = ref.read(mockApiServiceProvider);
    final profile = await api.getTenantProfile();
    final tenantName = (profile?['companyName'] as String?) ?? 'Tenant';
    final officeNumber = (profile?['unitOrOffice'] as String?) ?? 'N/A';
    final description =
        '$_selectedCategory: ${_complaintController.text.trim()}';

    await ref
        .read(complaintsProvider.notifier)
        .submitComplaint(
          tenantName: tenantName,
          officeNumber: officeNumber,
          description: description,
          type: _selectedComplaintType,
        );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Complaint submitted successfully!'),
        backgroundColor: AppColors.success,
      ),
    );
    _complaintController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final complaintsAsync = ref.watch(complaintsProvider);
    final profileAsync = ref.watch(tenantProfileProvider);
    final tenantName = profileAsync.asData?.value?.companyName;

    return Scaffold(
      appBar: AppBar(
        title: profileAsync.when(
          data: (profile) => Text(profile?.companyName ?? 'Complaints'),
          loading: () => const Text('Complaints'),
          error: (_, _) => const Text('Complaints'),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Submit Complaint Form
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Submit a Complaint',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Category Dropdown
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Maintenance',
                        child: Text('Maintenance'),
                      ),
                      DropdownMenuItem(
                        value: 'Cleaning',
                        child: Text('Cleaning'),
                      ),
                      DropdownMenuItem(
                        value: 'Security',
                        child: Text('Security'),
                      ),
                      DropdownMenuItem(
                        value: 'Parking',
                        child: Text('Parking'),
                      ),
                      DropdownMenuItem(value: 'Other', child: Text('Other')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Complaint Type
                  DropdownButtonFormField<String>(
                    initialValue: _selectedComplaintType,
                    decoration: const InputDecoration(
                      labelText: 'Complaint Type',
                      prefixIcon: Icon(Icons.forum_outlined),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'personal',
                        child: Text('Personal (Admin Only)'),
                      ),
                      DropdownMenuItem(
                        value: 'general',
                        child: Text('General (Visible to All Tenants)'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedComplaintType = value ?? 'personal';
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Complaint Text Field
                  TextFormField(
                    controller: _complaintController,
                    decoration: const InputDecoration(
                      labelText: 'Details',
                      hintText: 'Describe your issue...',
                      alignLabelWithHint: true,
                    ),
                    maxLines: 3,
                    validator: (value) => value?.isEmpty ?? true
                        ? 'Please provide details'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  ElevatedButton.icon(
                    onPressed: _submitComplaint,
                    icon: const Icon(Icons.send_rounded),
                    label: const Text('Submit Complaint'),
                  ),
                ],
              ),
            ),
          ),

          const Divider(height: 1),

          // My Complaints List
          Expanded(
            child: complaintsAsync.when(
              loading: () => const ShimmerList(height: 100),
              error: (e, _) => ErrorStateWidget(
                message: 'Failed to load complaints: $e',
                onRetry: () => ref.invalidate(complaintsProvider),
              ),
              data: (complaints) {
                final visible = complaints
                    .where(
                      (c) => c.type == 'general' ||
                          (tenantName != null && c.tenantName == tenantName),
                    )
                    .toList();

                if (visible.isEmpty) {
                  return const EmptyStateWidget(
                    icon: Icons.check_circle_outline_rounded,
                    title: 'No Complaints',
                    subtitle: 'Everything seems to be working perfectly!',
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: visible.length,
                  itemBuilder: (context, index) {
                    final complaint = visible[index];
                    final isOpen = complaint.status == 'Open';

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
                                  child: Text(
                                    complaint.description,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
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
                                    color:
                                        (isOpen
                                                ? AppColors.warning
                                                : AppColors.success)
                                            .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    complaint.status,
                                    style: TextStyle(
                                      color: isOpen
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
                            Row(
                              children: [
                                const Icon(
                                  Icons.access_time_rounded,
                                  size: 16,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _formatDate(complaint.timestamp),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            if (isOpen) ...[
                              const SizedBox(height: 12),
                              const LinearProgressIndicator(
                                value: 0.5,
                                backgroundColor: Color(0xFFE2E8F0),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.warning,
                                ),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'In Progress - Admin has been notified',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} minutes ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${difference.inDays} days ago';
    }
  }
}
