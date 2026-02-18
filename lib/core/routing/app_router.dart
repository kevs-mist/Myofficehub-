import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/splash_screen.dart';
import '../../features/role_selection_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/admin/presentation/admin_dashboard_screen.dart';
import '../../features/admin/presentation/admin_tenants_screen.dart';
import '../../features/admin/presentation/admin_events_screen.dart';
import '../../features/admin/presentation/admin_complaints_screen.dart';
import '../../features/admin/presentation/admin_profile_screen.dart';
import '../../features/admin/presentation/admin_cars_screen.dart';
import '../../features/admin/presentation/admin_office_help_screen.dart';
import '../../features/admin/presentation/admin_security_personnel_screen.dart';
import '../../features/tenant/presentation/tenant_dashboard_screen.dart';
import '../../features/tenant/presentation/tenant_payments_screen.dart';
import '../../features/tenant/presentation/tenant_events_screen.dart';
import '../../features/tenant/presentation/tenant_complaints_screen.dart';
import '../../features/tenant/presentation/tenant_profile_screen.dart';
import '../../features/tenant/presentation/tenant_analytics_screen.dart';
import '../widgets/main_nav_shell.dart';
import 'route_names.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    initialLocation: '/',
    navigatorKey: _rootNavigatorKey,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: '/',
        name: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/role-selection',
        name: RouteNames.roleSelection,
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: '/login',
        name: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: RouteNames.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),

      GoRoute(
        path: '/admin/cars',
        name: RouteNames.adminCars,
        builder: (context, state) => const AdminCarsScreen(),
      ),
      GoRoute(
        path: '/admin/office-help',
        name: RouteNames.adminOfficeHelp,
        builder: (context, state) => const AdminOfficeHelpScreen(),
      ),
      GoRoute(
        path: '/admin/security-personnel',
        name: RouteNames.adminSecurityPersonnel,
        builder: (context, state) => const AdminSecurityPersonnelScreen(),
      ),

      // Admin Stateful Navigation Shell
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainNavigationShell(navigationShell: navigationShell);
        },
        branches: [
          // Home / Dashboard
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin',
                name: RouteNames.adminDashboard,
                builder: (context, state) => const AdminDashboardScreen(),
              ),
            ],
          ),
          // Tenants
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/tenants',
                name: RouteNames.adminTenants,
                builder: (context, state) => const AdminTenantsScreen(),
              ),
            ],
          ),
          // Events
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/events',
                name: RouteNames.adminEvents,
                builder: (context, state) => const AdminEventsScreen(),
              ),
            ],
          ),
          // Complaints
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/complaints',
                name: RouteNames.adminComplaints,
                builder: (context, state) => const AdminComplaintsScreen(),
              ),
            ],
          ),
          // Profile
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/profile',
                name: RouteNames.adminProfile,
                builder: (context, state) => const AdminProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // Tenant Stateful Navigation Shell (Using same logic, routes are differentiated)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainNavigationShell(navigationShell: navigationShell);
        },
        branches: [
          // Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/tenant',
                name: RouteNames.tenantDashboard,
                builder: (context, state) => const TenantDashboardScreen(),
                routes: [
                  GoRoute(
                    path: 'analytics',
                    name: RouteNames.tenantAnalytics,
                    builder: (context, state) => const TenantAnalyticsScreen(),
                  ),
                ],
              ),
            ],
          ),
          // Payments
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/tenant/payments',
                name: RouteNames.tenantPayments,
                builder: (context, state) => const TenantPaymentsScreen(),
              ),
            ],
          ),
          // Events
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/tenant/events',
                name: RouteNames.tenantEvents,
                builder: (context, state) => const TenantEventsScreen(),
              ),
            ],
          ),
          // Complaints
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/tenant/complaints',
                name: RouteNames.tenantComplaints,
                builder: (context, state) => const TenantComplaintsScreen(),
              ),
            ],
          ),
          // Profile
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/tenant/profile',
                name: RouteNames.tenantProfile,
                builder: (context, state) => const TenantProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
