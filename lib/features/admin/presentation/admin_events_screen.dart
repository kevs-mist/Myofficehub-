import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/color_scheme.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/widgets/shimmer_widgets.dart';
import '../../../../providers/app_state_provider.dart';

class AdminEventsScreen extends ConsumerWidget {
  const AdminEventsScreen({super.key});

  Future<void> _showMinutesDialog(
    BuildContext context,
    WidgetRef ref, {
    required String eventId,
    required String initial,
  }) async {
    final controller = TextEditingController(text: initial);
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Minutes of Meeting'),
        content: TextField(
          controller: controller,
          maxLines: 8,
          decoration: const InputDecoration(
            hintText: 'Write meeting minutes here...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final minutes = controller.text.trim();
              await ref
                  .read(eventsProvider.notifier)
                  .updateEventMinutes(
                    eventId: eventId,
                    minutesOfMeeting: minutes,
                  );
              if (!context.mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Minutes updated successfully!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(eventsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Events'), elevation: 0),
      body: eventsAsync.when(
        loading: () => const ShimmerList(height: 120),
        error: (e, _) => ErrorStateWidget(
          message: 'Failed to load events: $e',
          onRetry: () => ref.invalidate(eventsProvider),
        ),
        data: (events) {
          if (events.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.event_busy_rounded,
              title: 'No Events Yet',
              subtitle:
                  'Schedule meetings or social gatherings for your tenants.',
              actionLabel: 'Create Event',
              onAction: () => _showCreateEventDialog(context, ref),
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
                final hasEnded = event.date.isBefore(DateTime.now());

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
                              Icons.location_on,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              event.location,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          event.description,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (event.minutesOfMeeting.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          const Divider(),
                          const SizedBox(height: 8),
                          const Text(
                            'Minutes of Meeting',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
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
                        if (hasEnded) ...[
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: OutlinedButton.icon(
                              onPressed: () => _showMinutesDialog(
                                context,
                                ref,
                                eventId: event.id,
                                initial: event.minutesOfMeeting,
                              ),
                              icon: const Icon(Icons.note_add_rounded),
                              label: Text(
                                event.minutesOfMeeting.isEmpty
                                    ? 'Add Minutes'
                                    : 'Edit Minutes',
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateEventDialog(context, ref),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Create Event'),
      ),
    );
  }

  void _showCreateEventDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final locationController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Event'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Event Title'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(labelText: 'Location'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final title = titleController.text.trim();
              final location = locationController.text.trim();
              final description = descriptionController.text.trim();
              if (title.isEmpty || location.isEmpty) return;

              await ref
                  .read(eventsProvider.notifier)
                  .createEvent(
                    title: title,
                    location: location,
                    description: description,
                  );

              if (!context.mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Event created successfully!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
