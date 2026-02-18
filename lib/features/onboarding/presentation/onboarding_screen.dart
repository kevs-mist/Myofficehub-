// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/color_scheme.dart';
import '../../../core/ui/app_layout.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/widgets/app_background.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../providers/role_provider.dart';
import '../../../providers/app_state_provider.dart';
import '../../../models/admin_model.dart';
import 'widgets/playful_input.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();

  final _orgController = TextEditingController();
  final _nameController = TextEditingController();
  final _locationOrUnitController = TextEditingController();
  final _carLicensePlateController = TextEditingController();
  final _parkingNumberController = TextEditingController();
  final _maintenanceFeeController = TextEditingController(text: '5000');
  final _whatsappGroupNumberController = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _orgController.dispose();
    _nameController.dispose();
    _locationOrUnitController.dispose();
    _carLicensePlateController.dispose();
    _parkingNumberController.dispose();
    _maintenanceFeeController.dispose();
    _whatsappGroupNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = ref.watch(roleProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: AppBackground(
        child: SingleChildScrollView(
          padding: AppLayout.screenInsetsWide,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // ROLE SPECIFIC ICON
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: (isAdmin ? AppColors.primary : AppColors.accent)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    isAdmin
                        ? Icons.admin_panel_settings_rounded
                        : Icons.person_pin_rounded,
                    color: isAdmin ? AppColors.primary : AppColors.accent,
                    size: 32,
                  ),
                ).animate().scale(curve: Curves.easeOutBack),

                AppLayout.v32,

                Text(
                  isAdmin
                      ? 'Create Complex Profile'
                      : 'Setting Up Your Workspace',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                    letterSpacing: -1.5,
                  ),
                ).animate().fadeIn().slideX(begin: -0.2),

                AppLayout.v12,

                Text(
                  isAdmin
                      ? 'Establish the digital backbone for your office complex.'
                      : 'Connect with your building management and start working better.',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  ),
                ).animate().fadeIn(delay: 200.ms),

                AppLayout.v48,

                PlayfulInput(
                  label: isAdmin ? 'Office Complex Name' : 'Your Company Name',
                  hint: isAdmin
                      ? 'e.g. World Trade Center'
                      : 'e.g. Google India',
                  icon: Icons.business_rounded,
                  color: isAdmin ? AppColors.primary : AppColors.accent,
                  controller: _orgController,
                ),
                AppLayout.v24,

                PlayfulInput(
                  label: 'Account Holder Name',
                  hint: 'e.g. Rajesh Kumar',
                  icon: Icons.person_rounded,
                  color: isAdmin ? AppColors.primary : AppColors.accent,
                  controller: _nameController,
                ),
                AppLayout.v24,

                PlayfulInput(
                  label: isAdmin
                      ? 'Primary Location'
                      : 'Assigned Unit / Office Number',
                  hint: isAdmin ? 'e.g. Bangalore, KA' : 'e.g. A-Gate, Floor 4',
                  icon: isAdmin
                      ? Icons.map_rounded
                      : Icons.door_front_door_rounded,
                  color: isAdmin ? AppColors.primary : AppColors.accent,
                  controller: _locationOrUnitController,
                ),
                if (isAdmin) ...[
                  AppLayout.v24,
                  PlayfulInput(
                    label: 'Maintenance Fee (₹)',
                    hint: 'e.g. 5000',
                    icon: Icons.currency_rupee_rounded,
                    color: AppColors.primary,
                    controller: _maintenanceFeeController,
                  ),
                  AppLayout.v24,
                  PlayfulInput(
                    label: 'WhatsApp Group Number',
                    hint: 'e.g. +91 9000000000',
                    icon: Icons.chat_rounded,
                    color: AppColors.primary,
                    controller: _whatsappGroupNumberController,
                  ),
                ],
                if (!isAdmin) ...[
                  AppLayout.v24,
                  PlayfulInput(
                    label: 'Car License Plate Number',
                    hint: 'e.g. KA 01 AB 1234',
                    icon: Icons.directions_car_rounded,
                    color: AppColors.accent,
                    controller: _carLicensePlateController,
                  ),
                  AppLayout.v24,
                  PlayfulInput(
                    label: 'Parking Number',
                    hint: 'e.g. P-14',
                    icon: Icons.local_parking_rounded,
                    color: AppColors.accent,
                    controller: _parkingNumberController,
                  ),
                ],
                AppLayout.v48,

                GradientButton(
                  onPressed: _busy
                      ? null
                      : () async {
                          if (!_formKey.currentState!.validate()) return;

                          setState(() => _busy = true);

                          try {
                            final isAdmin = ref.read(roleProvider);
                            final api = ref.read(mockApiServiceProvider);
                            final user = FirebaseAuth.instance.currentUser;
                            final email = user?.email ?? 'unknown@user.com';

                            final org = _orgController.text.trim();
                            final name = _nameController.text.trim();
                            final locOrUnit = _locationOrUnitController.text
                                .trim();
                            final carLicensePlateNumber =
                                _carLicensePlateController.text.trim();
                            final parkingNumber = _parkingNumberController.text
                                .trim();
                            final maintenanceFeeRaw = _maintenanceFeeController
                                .text
                                .trim();
                            final whatsappGroupNumber =
                                _whatsappGroupNumberController.text.trim();

                            if (isAdmin) {
                              final maintenanceFee =
                                  double.tryParse(maintenanceFeeRaw) ?? 0;
                              final admin = AdminModel(
                                id: user?.uid ?? '',
                                name: name,
                                email: email,
                                phoneNumber: '',
                                officeComplexName: org,
                                maintenanceFee: maintenanceFee,
                                parkingFee: 1500,
                                lateFee: 0,
                                upiId: '',
                                whatsappGroupNumber: whatsappGroupNumber,
                              );
                              await api.resetForNewAccount(adminProfile: admin);
                            } else {
                              await api.resetForNewAccount(
                                tenantProfile: {
                                  'companyName': org,
                                  'accountHolderName': name,
                                  'unitOrOffice': locOrUnit,
                                  'carLicensePlateNumber':
                                      carLicensePlateNumber,
                                  'parkingNumber': parkingNumber,
                                },
                              );
                            }

                            ref.invalidate(tenantsProvider);
                            ref.invalidate(eventsProvider);
                            ref.invalidate(complaintsProvider);
                            ref.invalidate(adminProfileProvider);

                            if (!mounted) return;
                            if (isAdmin) {
                              context.goNamed(RouteNames.adminDashboard);
                            } else {
                              context.goNamed(RouteNames.tenantDashboard);
                            }
                          } catch (e) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Setup failed: ${e.toString()}'),
                              ),
                            );
                          } finally {
                            if (mounted) {
                              setState(() => _busy = false);
                            }
                          }
                        },
                  label: _busy ? 'SETTING UP...' : 'FINISH SETUP',
                  gradient: isAdmin
                      ? AppColors.primaryGradient
                      : AppColors.accentGradient,
                  height: 64,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: (isAdmin ? AppColors.primary : AppColors.accent)
                          .withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ).animate().fadeIn(delay: 400.ms).scale(),

                AppLayout.v40,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
