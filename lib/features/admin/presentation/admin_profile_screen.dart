// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/theme/color_scheme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../models/admin_model.dart';
import '../../../../providers/app_state_provider.dart';
import 'providers/admin_dashboard_provider.dart';

class AdminProfileScreen extends ConsumerStatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  ConsumerState<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends ConsumerState<AdminProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _officeNameController;
  late TextEditingController _maintenanceFeeController;
  late TextEditingController _parkingFeeController;
  late TextEditingController _lateFeeController;
  late TextEditingController _upiIdController;
  late TextEditingController _whatsappGroupNumberController;

  AdminModel? _loadedAdmin;
  bool _isSaving = false;
  bool _isLoading = true;
  bool _notificationsEnabled = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'Rajesh Kumar');
    _emailController = TextEditingController(text: 'admin@skyline.com');
    _phoneController = TextEditingController(text: '+91 9876543210');
    _officeNameController = TextEditingController(
      text: 'Skyline Business Park',
    );
    _maintenanceFeeController = TextEditingController(text: '5000');
    _parkingFeeController = TextEditingController(text: '1500');
    _lateFeeController = TextEditingController(text: '0');
    _upiIdController = TextEditingController(text: 'skyline@upi');
    _whatsappGroupNumberController = TextEditingController();

    Future.microtask(() async {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _notificationsEnabled = prefs.getBool('notifications_enabled') ?? false;
      });

      try {
        final api = ref.read(mockApiServiceProvider);
        final admin = await api.getAdminProfile();
        if (!mounted) return;
        setState(() {
          _loadedAdmin = admin;
          _nameController.text = admin.name;
          _emailController.text = admin.email;
          _phoneController.text = admin.phoneNumber;
          _officeNameController.text = admin.officeComplexName;
          _maintenanceFeeController.text = admin.maintenanceFee.toStringAsFixed(
            0,
          );
          _parkingFeeController.text = admin.parkingFee.toStringAsFixed(0);
          _lateFeeController.text = admin.lateFee.toStringAsFixed(0);
          _upiIdController.text = admin.upiId;
          _whatsappGroupNumberController.text = admin.whatsappGroupNumber;
          _isLoading = false;
        });
      } catch (_) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _officeNameController.dispose();
    _maintenanceFeeController.dispose();
    _parkingFeeController.dispose();
    _lateFeeController.dispose();
    _upiIdController.dispose();
    _whatsappGroupNumberController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final base = _loadedAdmin;
      if (base == null) return;

      final maintenanceFee =
          double.tryParse(_maintenanceFeeController.text.trim()) ??
          base.maintenanceFee;
      final parkingFee =
          double.tryParse(_parkingFeeController.text.trim()) ?? base.parkingFee;
      final lateFee =
          double.tryParse(_lateFeeController.text.trim()) ?? base.lateFee;

      final updated = AdminModel(
        id: base.id,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        officeComplexName: _officeNameController.text.trim(),
        maintenanceFee: maintenanceFee,
        parkingFee: parkingFee,
        lateFee: lateFee,
        upiId: _upiIdController.text.trim(),
        whatsappGroupNumber: _whatsappGroupNumberController.text.trim(),
      );

      final api = ref.read(mockApiServiceProvider);
      await api.saveAdminProfile(updated);

      // Invalidate providers to refresh data across the app
      ref.invalidate(adminProfileProvider);
      ref.invalidate(adminDashboardProvider);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Profile'),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: const Text(
              'Save',
              style: TextStyle(
                color: AppColors.primary,
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
                    // Profile Picture
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: AppColors.primary.withValues(
                              alpha: 0.1,
                            ),
                            child: const Icon(
                              Icons.person,
                              size: 50,
                              color: AppColors.primary,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
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
                      'Personal Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: 32),

                    const Text(
                      'Office Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _officeNameController,
                      decoration: const InputDecoration(
                        labelText: 'Office Complex Name',
                        prefixIcon: Icon(Icons.business),
                      ),
                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: 32),

                    const Text(
                      'Fee Structure',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _maintenanceFeeController,
                      decoration: const InputDecoration(
                        labelText: 'Maintenance Fee (₹)',
                        prefixIcon: Icon(Icons.currency_rupee),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _parkingFeeController,
                      decoration: const InputDecoration(
                        labelText: 'Parking Fee (₹)',
                        prefixIcon: Icon(Icons.local_parking),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _lateFeeController,
                      decoration: const InputDecoration(
                        labelText: 'Late Fee (₹)',
                        prefixIcon: Icon(Icons.warning_amber_rounded),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _upiIdController,
                      decoration: const InputDecoration(
                        labelText: 'UPI ID',
                        prefixIcon: Icon(Icons.payment),
                      ),
                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _whatsappGroupNumberController,
                      decoration: const InputDecoration(
                        labelText: 'WhatsApp Group (Link)',
                        prefixIcon: Icon(Icons.link),
                      ),
                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
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
                          'Receive alerts for complaints & events',
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
                    const SizedBox(height: 40),

                    ElevatedButton(
                      onPressed: _isSaving ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Save Changes'),
                    ),
                    const SizedBox(height: 16),

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
                  ],
                ),
              ),
            ),
    );
  }
}
