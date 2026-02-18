import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../providers/app_state_provider.dart';
import '../../../../models/admin_model.dart';

class AdminDashboardState {
  final bool isLoading;
  final AdminModel? adminProfile;
  final int totalTenants;
  final int totalVehicles;
  final int staffCount;
  final double totalCollected;
  final double totalPending;
  final double collectionRate;
  final int paymentPaidCount;
  final int paymentPendingCount;
  final int paymentOverdueCount;
  final double occupancyRate;
  final List<double> revenueTrends; // Last 6 months

  AdminDashboardState({
    this.isLoading = true,
    this.adminProfile,
    this.totalTenants = 0,
    this.totalVehicles = 0,
    this.staffCount = 0,
    this.totalCollected = 0.0,
    this.totalPending = 0.0,
    this.collectionRate = 0.0,
    this.paymentPaidCount = 0,
    this.paymentPendingCount = 0,
    this.paymentOverdueCount = 0,
    this.occupancyRate = 0.0,
    this.revenueTrends = const [],
  });
}

final adminDashboardProvider = FutureProvider.autoDispose<AdminDashboardState>((
  ref,
) async {
  final api = ref.watch(mockApiServiceProvider);

  try {
    final admin = await api.getAdminProfile();
    final tenants = await api.getTenants();
    final payments = await api.getPayments();
    final staff = await api.getStaffCount();

    final int vehicles = tenants.fold(0, (sum, t) => sum + t.vehicleCount);

    double collected = 0;
    double pending = 0;
    int paidCount = 0;
    int pendingCount = 0;
    int overdueCount = 0;

    for (var p in payments) {
      if (p.status == 'Paid') {
        collected += p.amount;
        paidCount++;
      } else {
        final isOverdue =
            p.status == 'Overdue' && p.dueDate.isBefore(DateTime.now());
        pending += p.amount + (isOverdue ? admin.lateFee : 0);
        if (p.status == 'Pending') pendingCount++;
        if (p.status == 'Overdue') overdueCount++;
      }
    }

    final double rate = (collected + pending) > 0
        ? (collected / (collected + pending)) * 100
        : 0;

    // Advanced Metrics
    const int totalUnits = 50; // Demo capacity
    final double occupancy = (tenants.length / totalUnits) * 100;

    // Monthly Trends (Mocking last 6 months of collected revenue)
    final List<double> trends = [
      collected * 0.85,
      collected * 0.92,
      collected * 0.88,
      collected * 0.95,
      collected * 0.98,
      collected,
    ];

    return AdminDashboardState(
      isLoading: false,
      adminProfile: admin,
      totalTenants: tenants.length,
      totalVehicles: vehicles,
      staffCount: staff,
      totalCollected: collected,
      totalPending: pending,
      collectionRate: rate,
      paymentPaidCount: paidCount,
      paymentPendingCount: pendingCount,
      paymentOverdueCount: overdueCount,
      occupancyRate: occupancy,
      revenueTrends: trends,
    );
  } catch (e) {
    return AdminDashboardState(isLoading: false);
  }
});
