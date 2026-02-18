import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/color_scheme.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/widgets/shimmer_widgets.dart';
import '../../../../providers/tenant_profile_provider.dart';
import '../../../../providers/app_state_provider.dart';

class TenantEventsScreen extends ConsumerWidget {
  const TenantEventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(eventsProvider);
    final profileAsync = ref.watch(tenantProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: profileAsync.when(
          data: (profile) => Text(profile?.companyName ?? 'Events'),
          loading: () => const Text('Events'),
          error: (_, _) => const Text('Events'),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: eventsAsync.when(
        loading: () => const ShimmerList(height: 120),
        error: (e, _) => ErrorStateWidget(
          message: 'Failed to load events: $e',
          onRetry: () => ref.invalidate(eventsProvider),
        ),
        data: (events) {
          if (events.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.event_available_rounded,
              title: 'No Events',
              subtitle:
                  'There are no upcoming events scheduled at the moment. Check back later!',
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.refresh(eventsProvider.future),
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                final dateFormat = DateFormat('MMM dd, yyyy');
                final timeFormat = DateFormat('hh:mm a');

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.event,
                                color: AppColors.accent,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    event.title,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    dateFormat.format(event.date),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              timeFormat.format(event.date),
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Icon(
                              Icons.location_on,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                event.location,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          event.description,
                          style: const TextStyle(color: AppColors.textPrimary),
                        ),
                        if (event.minutesOfMeeting.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          const Divider(),
                          const SizedBox(height: 8),
                          const Text(
                            'Minutes of Meeting',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            event.minutesOfMeeting,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        const Text(
                          'Will you attend?',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () =>
                                    _handleRSVP(context, event.title, 'Yes'),
                                icon: const Icon(Icons.check_circle, size: 18),
                                label: const Text('Yes'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.success,
                                  side: const BorderSide(
                                    color: AppColors.success,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () =>
                                    _handleRSVP(context, event.title, 'Maybe'),
                                icon: const Icon(Icons.help_outline, size: 18),
                                label: const Text('Maybe'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.warning,
                                  side: const BorderSide(
                                    color: AppColors.warning,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () =>
                                    _handleRSVP(context, event.title, 'No'),
                                icon: const Icon(Icons.cancel, size: 18),
                                label: const Text('No'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.error,
                                  side: const BorderSide(
                                    color: AppColors.error,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _handleRSVP(BuildContext context, String eventTitle, String response) {
    final color = response == 'Yes'
        ? AppColors.success
        : response == 'Maybe'
        ? AppColors.warning
        : AppColors.error;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('RSVP submitted: $response for "$eventTitle"'),
        backgroundColor: color,
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }
}
