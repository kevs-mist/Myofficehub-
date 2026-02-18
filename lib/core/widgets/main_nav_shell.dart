import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/color_scheme.dart';
import '../services/haptic_service.dart';
import '../../providers/role_provider.dart';

class MainNavigationShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const MainNavigationShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(roleProvider);

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color:
              Theme.of(context).bottomNavigationBarTheme.backgroundColor ??
              Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: NavigationBar(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: (index) {
              HapticService.light();
              navigationShell.goBranch(index);
            },
            backgroundColor: Colors.transparent,
            elevation: 0,
            indicatorColor: AppColors.primary.withValues(alpha: 0.1),
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home, color: AppColors.primary),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(
                  isAdmin ? Icons.business_outlined : Icons.payment_outlined,
                ),
                selectedIcon: Icon(
                  isAdmin ? Icons.business : Icons.payment,
                  color: AppColors.primary,
                ),
                label: isAdmin ? 'Tenants' : 'Payments',
              ),
              const NavigationDestination(
                icon: Icon(Icons.event_outlined),
                selectedIcon: Icon(
                  Icons.event_available,
                  color: AppColors.primary,
                ),
                label: 'Events',
              ),
              const NavigationDestination(
                icon: Icon(Icons.error_outline_rounded),
                selectedIcon: Icon(
                  Icons.error_rounded,
                  color: AppColors.primary,
                ),
                label: 'Complaints',
              ),
              const NavigationDestination(
                icon: Icon(Icons.person_outline_rounded),
                selectedIcon: Icon(
                  Icons.person_rounded,
                  color: AppColors.primary,
                ),
                label: 'Me',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
