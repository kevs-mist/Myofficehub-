import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/color_scheme.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/widgets/shimmer_widgets.dart';
import '../../../../models/car_model.dart';
import '../../../../providers/app_state_provider.dart';

class AdminCarsScreen extends ConsumerWidget {
  const AdminCarsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final carsAsync = ref.watch(carsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Cars'), elevation: 0),
      body: carsAsync.when(
        loading: () => const ShimmerList(height: 80),
        error: (e, _) => ErrorStateWidget(
          message: 'Failed to load cars: $e',
          onRetry: () => ref.invalidate(carsProvider),
        ),
        data: (cars) {
          if (cars.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.directions_car_rounded,
              title: 'No Cars',
              subtitle: 'No cars have been registered yet.',
            );
          }

          final grouped = <String, List<CarModel>>{};
          for (final c in cars) {
            final key = '${c.tenantName} • ${c.officeNumber}';
            grouped.putIfAbsent(key, () => []).add(c);
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: grouped.entries.map((e) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.accent.withValues(alpha: 0.12),
                    child: const Icon(
                      Icons.local_parking_rounded,
                      color: AppColors.accent,
                    ),
                  ),
                  title: Text(e.key),
                  subtitle: Text('${e.value.length} cars'),
                  children: [
                    for (final car in e.value)
                      ListTile(
                        leading: const Icon(Icons.directions_car_rounded),
                        title: Text(car.licensePlateNumber),
                        subtitle: Text('Parking: ${car.parkingNumber}'),
                      ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
