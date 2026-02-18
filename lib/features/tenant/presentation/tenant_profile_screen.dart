// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/color_scheme.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../providers/app_state_provider.dart';
import '../../../../providers/tenant_profile_provider.dart';
import '../../../../models/tenant_profile_model.dart';

class TenantProfileScreen extends ConsumerStatefulWidget {
  const TenantProfileScreen({super.key});

  @override
  ConsumerState<TenantProfileScreen> createState() =>
      _TenantProfileScreenState();
}

class _TenantProfileScreenState extends ConsumerState<TenantProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _companyNameController;
  late TextEditingController _accountHolderNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _officeNumberController;
  late TextEditingController _carLicensePlateController;
  late TextEditingController _parkingNumberController;

  bool _isLoading = true;
  bool _isSaving = false;
  bool _notificationsEnabled = false;

  @override
  void initState() {
    super.initState();
    _companyNameController = TextEditingController();
    _accountHolderNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _officeNumberController = TextEditingController();
    _carLicensePlateController = TextEditingController();
    _parkingNumberController = TextEditingController();

    Future.microtask(() async {
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() {
          _notificationsEnabled =
              prefs.getBool('notifications_enabled') ?? false;
        });
      }

      try {
        final profile = await ref.read(tenantProfileProvider.future);
        final user = FirebaseAuth.instance.currentUser;
        if (!mounted) return;

        setState(() {
          if (profile != null) {
            _companyNameController.text = profile.companyName;
            _accountHolderNameController.text = profile.accountHolderName;
            _officeNumberController.text = profile.unitOrOffice;
            _carLicensePlateController.text = profile.carLicensePlateNumber;
            _parkingNumberController.text = profile.parkingNumber;
          }
          _emailController.text = user?.email ?? '';
          _isLoading = false;
        });
      } catch (_) {
        if (mounted) setState(() => _isLoading = false);
      }
    });
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _accountHolderNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _officeNumberController.dispose();
    _carLicensePlateController.dispose();
    _parkingNumberController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final updated = TenantProfileModel(
        companyName: _companyNameController.text.trim(),
        accountHolderName: _accountHolderNameController.text.trim(),
        unitOrOffice: _officeNumberController.text.trim(),
        carLicensePlateNumber: _carLicensePlateController.text.trim(),
        parkingNumber: _parkingNumberController.text.trim(),
      );

      final api = ref.read(mockApiServiceProvider);
      await api.saveTenantProfile(
        companyName: updated.companyName,
        accountHolderName: updated.accountHolderName,
        unitOrOffice: updated.unitOrOffice,
        carLicensePlateNumber: updated.carLicensePlateNumber,
        parkingNumber: updated.parkingNumber,
      );

      // Invalidate provider to refresh data
      ref.invalidate(tenantProfileProvider);
      ref.invalidate(carsProvider);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tenant Profile'),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveProfile,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: AppColors.accent.withValues(
                              alpha: 0.1,
                            ),
                            child: const Icon(
                              Icons.business,
                              size: 50,
                              color: AppColors.accent,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: AppColors.accent,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Company Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _companyNameController,
                      decoration: const InputDecoration(
                        labelText: 'Company Name',
                        prefixIcon: Icon(Icons.business),
                      ),
                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _accountHolderNameController,
                      decoration: const InputDecoration(
                        labelText: 'Account Holder Name',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Business Email',
                        prefixIcon: Icon(Icons.email),
                      ),
                      enabled: false, // Usually email is managed at login
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _officeNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Office Number / Unit',
                        prefixIcon: Icon(Icons.door_front_door),
                      ),
                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Vehicle & Parking',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _carLicensePlateController,
                      decoration: const InputDecoration(
                        labelText: 'Car License Plate',
                        prefixIcon: Icon(Icons.directions_car),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _parkingNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Assigned Parking',
                        prefixIcon: Icon(Icons.local_parking),
                      ),
                    ),
                    const SizedBox(height: 32),

                    const Text(
                      'Preferences',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: SwitchListTile(
                        secondary: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.notifications_active_rounded,
                            color: AppColors.accent,
                          ),
                        ),
                        title: const Text('Push Notifications'),
                        subtitle: const Text(
                          'Receive alerts for payments & events',
                        ),
                        value: _notificationsEnabled,
                        onChanged: (bool value) async {
                          final prefs = await SharedPreferences.getInstance();
                          if (value) {
                            final success = await ref
                                .read(notificationServiceProvider)
                                .requestPermissions();
                            if (success) {
                              setState(() => _notificationsEnabled = true);
                              await prefs.setBool(
                                'notifications_enabled',
                                true,
                              );
                            } else {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Permission denied by user'),
                                ),
                              );
                            }
                          } else {
                            await ref
                                .read(notificationServiceProvider)
                                .disableNotifications();
                            setState(() => _notificationsEnabled = false);
                            await prefs.setBool('notifications_enabled', false);
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Account Status',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _InfoRow(label: 'Member Since', value: 'Jan 2024'),
                            const SizedBox(height: 8),
                            _InfoRow(label: 'Account Status', value: 'Active'),
                            const SizedBox(height: 8),
                            _InfoRow(
                              label: 'Payment Status',
                              value: 'Up to date',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),
                    OutlinedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Logout'),
                            content: const Text(
                              'Are you sure you want to logout?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  try {
                                    await FirebaseAuth.instance.signOut();
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Logged out successfully',
                                        ),
                                        backgroundColor: AppColors.primary,
                                      ),
                                    );
                                    context.goNamed(RouteNames.roleSelection);
                                  } catch (e) {
                                    if (!mounted) return;
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Logout failed: $e'),
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.error,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Logout'),
                              ),
                            ],
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                      ),
                      child: const Text('Logout'),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
