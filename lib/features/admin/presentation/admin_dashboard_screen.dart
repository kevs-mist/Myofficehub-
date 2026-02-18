import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/color_scheme.dart';
import '../../../../core/ui/app_layout.dart';
import '../../../../core/widgets/app_background.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/routing/route_names.dart';
import 'providers/admin_dashboard_provider.dart';
import 'widgets/revenue_chart.dart';
import 'widgets/admin_dashboard_widgets.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(adminDashboardProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: AppBackground(
        child: asyncState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
          data: (state) {
            final admin = state.adminProfile;
            final currencyFormat = NumberFormat.compactCurrency(
              symbol: '₹',
              decimalDigits: 0,
            );

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  expandedHeight: 130,
                  floating: true,
                  pinned: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: const EdgeInsets.only(
                      left: 24,
                      bottom: 20,
                      right: 24,
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Good Morning,',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              admin?.name.split(' ').first ?? 'Admin',
                              style: theme.textTheme.displayMedium?.copyWith(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ).animate().fadeIn(duration: 600.ms),
                        const CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.accent,
                          child: Icon(
                            Icons.person_outline,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: AppLayout.screenInsets,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppLayout.v8,

                        // SYNTHESIS HERO CARD
                        Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(30),
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(28),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.2,
                                    ),
                                    blurRadius: 25,
                                    offset: const Offset(0, 12),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'FINANCIAL REVENUE',
                                        style: TextStyle(
                                          color: Colors.white54,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                      Icon(
                                        Icons.insights_rounded,
                                        color: AppColors.accent,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                  AppLayout.v24,
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        currencyFormat.format(
                                          state.totalCollected,
                                        ),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 38,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.only(
                                          left: 8,
                                          bottom: 8,
                                        ),
                                        child: Text(
                                          'Current Month',
                                          style: TextStyle(
                                            color: Colors.white60,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 28),
                                  CompactMetric(
                                    label: 'Monthly Collection Progress',
                                    value: state.collectionRate / 100,
                                    color: AppColors.accent,
                                  ),
                                ],
                              ),
                            )
                            .animate()
                            .fadeIn(duration: 600.ms)
                            .slideY(begin: 0.1, end: 0),

                        AppLayout.v32,
                        const SectionHeader(
                          title: '📊 Revenue Trends (Last 6 Months)',
                        ),
                        AppLayout.v16,
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: RevenueChart(trends: state.revenueTrends),
                          ),
                        ),

                        AppLayout.v32,
                        const SectionHeader(title: '🏢 Complex Key Metrics'),
                        AppLayout.v12,

                        Row(
                          children: [
                            Expanded(
                              child: MetricBox(
                                label: 'Tenants',
                                value: state.totalTenants.toString(),
                                icon: Icons.business_rounded,
                                accentColor: AppColors.accent,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: MetricBox(
                                label: 'Occupancy',
                                value:
                                    '${state.occupancyRate.toStringAsFixed(1)}%',
                                icon: Icons.pie_chart_outline_rounded,
                                accentColor: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                        AppLayout.v16,
                        Row(
                          children: [
                            Expanded(
                              child: MetricBox(
                                label: 'Security Staff',
                                value: state.staffCount.toString(),
                                icon: Icons.shield_outlined,
                                accentColor: AppColors.highlight,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: MetricBox(
                                label: 'Vehicles',
                                value: state.totalVehicles.toString(),
                                icon: Icons.directions_car_rounded,
                                accentColor: AppColors.primary,
                              ),
                            ),
                          ],
                        ),

                        const SectionHeader(title: '⚡ Quick Access'),
                        AppLayout.v12,
                        Row(
                          children: [
                            Expanded(
                              child: QuickButton(
                                label: 'Add Tenant',
                                icon: Icons.person_add_rounded,
                                color: AppColors.primary,
                                onTap: () =>
                                    context.pushNamed(RouteNames.adminTenants),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: QuickButton(
                                label: 'Add Event',
                                icon: Icons.event_available_rounded,
                                color: AppColors.accent,
                                onTap: () =>
                                    context.pushNamed(RouteNames.adminEvents),
                              ),
                            ),
                          ],
                        ),
                        AppLayout.v16,
                        ModernListItem(
                          icon: Icons.directions_car_filled_rounded,
                          title: 'Cars',
                          subtitle: 'See which tenants have which cars',
                          color: AppColors.accent,
                          onTap: () => context.pushNamed(RouteNames.adminCars),
                        ),
                        const SizedBox(height: 12),
                        ModernListItem(
                          icon: Icons.cleaning_services_rounded,
                          title: 'Office Help',
                          subtitle: 'See which offices employ office help',
                          color: AppColors.primary,
                          onTap: () =>
                              context.pushNamed(RouteNames.adminOfficeHelp),
                        ),
                        const SizedBox(height: 12),
                        ModernListItem(
                          icon: Icons.shield_rounded,
                          title: 'Security Personnel',
                          subtitle: 'View total security staff with details',
                          color: AppColors.highlight,
                          onTap: () => context.pushNamed(
                            RouteNames.adminSecurityPersonnel,
                          ),
                        ),
                        AppLayout.v32,
                        const SectionHeader(title: '🔔 Priority Feed'),
                        AppLayout.v12,

                        ModernListItem(
                          icon: Icons.notifications_active_outlined,
                          title: 'Invoice Overdue Notification',
                          subtitle:
                              '${state.paymentOverdueCount} companies require follow-up',
                          color: AppColors.error,
                          onTap: () =>
                              context.pushNamed(RouteNames.adminTenants),
                        ),
                        const SizedBox(height: 12),
                        ModernListItem(
                          icon: Icons.event_note_outlined,
                          title: 'Facility Event',
                          subtitle: 'Networking tea scheduled for Friday',
                          color: AppColors.success,
                          onTap: () =>
                              context.pushNamed(RouteNames.adminEvents),
                        ),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
