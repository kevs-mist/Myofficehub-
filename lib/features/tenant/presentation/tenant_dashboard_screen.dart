import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/color_scheme.dart';
import '../../../../core/ui/app_layout.dart';
import '../../../../core/widgets/app_background.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/widgets/shimmer_widgets.dart';
import '../../../../providers/tenant_profile_provider.dart';
import '../../../../providers/app_state_provider.dart';
import 'widgets/tenant_dashboard_widgets.dart';

class TenantDashboardScreen extends ConsumerWidget {
  const TenantDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tenantProfileAsync = ref.watch(tenantProfileProvider);
    final paymentsAsync = ref.watch(paymentsProvider);

    return Scaffold(
      body: AppBackground(
        child: RefreshIndicator(
          onRefresh: () async {
            HapticService.medium();
            await Future.wait([
              ref.refresh(tenantProfileProvider.future),
              ref.refresh(paymentsProvider.future),
              ref.refresh(eventsProvider.future),
            ]);
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
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
                            'My Dashboard,',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          tenantProfileAsync.when(
                            data: (profile) => Text(
                              profile?.companyName ?? 'My Workspace',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            loading: () => const ShimmerCard(
                              height: 24,
                              width: 120,
                              borderRadius: 4,
                            ),
                            error: (_, _) => const Text('My Workspace'),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.rocket_launch_rounded,
                          color: AppColors.primary,
                          size: 20,
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

                      // SYNTHESIS INVOICE CARD
                      paymentsAsync
                          .when(
                            data: (payments) {
                              final pendingPayments = payments
                                  .where((p) => p.status != 'Paid')
                                  .toList();
                              final totalDue = pendingPayments.fold<double>(
                                0,
                                (sum, p) => sum + p.amount,
                              );

                              return Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(30),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(28),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.2,
                                      ),
                                      blurRadius: 25,
                                      offset: const Offset(0, 10),
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
                                          'MONTHLY STATEMENT',
                                          style: TextStyle(
                                            color: Colors.white54,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                        if (totalDue > 0)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.highlight
                                                  .withValues(alpha: 0.2),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: const Text(
                                              'DUE',
                                              style: TextStyle(
                                                color: AppColors.highlight,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                          )
                                        else
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.success
                                                  .withValues(alpha: 0.2),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: const Text(
                                              'CLEAR',
                                              style: TextStyle(
                                                color: AppColors.success,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      '₹${totalDue.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 38,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      totalDue > 0
                                          ? 'Pending Maintenance & Facility Fees'
                                          : 'No outstanding dues for this month',
                                      style: const TextStyle(
                                        color: Colors.white54,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 32),
                                    ElevatedButton(
                                      onPressed: () => context.pushNamed(
                                        RouteNames.tenantPayments,
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.accent,
                                        foregroundColor: Colors.white,
                                        minimumSize: const Size(
                                          double.infinity,
                                          56,
                                        ),
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            totalDue > 0
                                                ? 'SETTLE NOW'
                                                : 'VIEW HISTORY',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Icon(
                                            Icons.arrow_forward_rounded,
                                            size: 18,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            loading: () => const ShimmerCard(
                              height: 240,
                              borderRadius: 28,
                            ),
                            error: (_, _) => const SizedBox(),
                          )
                          .animate()
                          .fadeIn(duration: 600.ms)
                          .slideY(begin: 0.1, end: 0),

                      AppLayout.v32,

                      const SectionHeader(title: '📅 Facility Timeline'),
                      AppLayout.v12,

                      const TimelineItem(
                        title: 'Scheduled Maintenance',
                        time: '27 Jan, 10:30 AM',
                        icon: Icons.plumbing_rounded,
                        color: Colors.indigo,
                      ),
                      const SizedBox(height: 12),
                      TimelineItem(
                        title: 'Tech Meetup - Networking',
                        time: '30 Jan, 04:00 PM',
                        icon: Icons.groups_2_outlined,
                        color: AppColors.highlight,
                      ),

                      AppLayout.v32,
                      const SectionHeader(title: '⚡ Quick Access'),
                      AppLayout.v12,

                      Row(
                        children: [
                          Expanded(
                            child: QuickActionCard(
                              title: 'Stats',
                              icon: Icons.analytics_outlined,
                              onTap: () =>
                                  context.pushNamed(RouteNames.tenantAnalytics),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: QuickActionCard(
                              title: 'Support',
                              icon: Icons.chat_bubble_outline_rounded,
                              onTap: () => context.pushNamed(
                                RouteNames.tenantComplaints,
                              ),
                            ),
                          ),
                        ],
                      ).animate().fadeIn(delay: 500.ms),

                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
