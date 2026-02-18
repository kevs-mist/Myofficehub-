import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/color_scheme.dart';
import '../core/ui/app_layout.dart';
import '../core/widgets/app_background.dart';
import '../core/routing/route_names.dart';
import '../providers/role_provider.dart';

class RoleSelectionScreen extends ConsumerWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
            child: Padding(
              padding: AppLayout.screenInsetsWide,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),
                  const Text(
                        'Get Started',
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                          letterSpacing: -1.5,
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .slideX(begin: -0.1, end: 0),
                  const SizedBox(height: 12),
                  const Text(
                    'Select your role to start managing\nyour workspace ecosystem.',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1, end: 0),

                  const Spacer(),

                  _SynthesizedRoleCard(
                    title: 'Administrator',
                    subtitle: 'Full complex & financial control',
                    icon: Icons.shield_rounded,
                    isMain: true,
                    onTap: () {
                      ref.read(roleProvider.notifier).setAdmin();
                      context.goNamed(RouteNames.login);
                    },
                    delay: 400.ms,
                  ),
                  const SizedBox(height: 24),
                  _SynthesizedRoleCard(
                    title: 'Resident Tenant',
                    subtitle: 'Access bills & facility updates',
                    icon: Icons.business_center_rounded,
                    isMain: false,
                    onTap: () {
                      ref.read(roleProvider.notifier).setTenant();
                      context.goNamed(RouteNames.login);
                    },
                    delay: 600.ms,
                  ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
      ),
    );
  }
}

class _SynthesizedRoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isMain;
  final VoidCallback onTap;
  final Duration delay;

  const _SynthesizedRoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isMain,
    required this.onTap,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: isMain ? AppColors.primary : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24),
          border: isMain ? null : Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: (isMain ? AppColors.primary : Colors.black).withValues(
                alpha: 0.1,
              ),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isMain
                    ? Colors.white10
                    : AppColors.accent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: isMain ? Colors.white : AppColors.accent,
                size: 32,
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isMain ? Colors.white : AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: isMain ? Colors.white60 : AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isMain ? Colors.white24 : const Color(0xFFCBD5E1),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: delay).slideY(begin: 0.1, end: 0);
  }
}
