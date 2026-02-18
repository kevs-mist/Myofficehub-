import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../providers/app_state_provider.dart';

class TenantAnalyticsState {
  final bool isLoading;
  final List<double> monthlyPayments;
  final Map<String, int> complaintStats;
  final double totalSpent;
  final int activeComplaints;

  TenantAnalyticsState({
    this.isLoading = true,
    this.monthlyPayments = const [],
    this.complaintStats = const {},
    this.totalSpent = 0.0,
    this.activeComplaints = 0,
  });
}

final tenantAnalyticsProvider =
    FutureProvider.autoDispose<TenantAnalyticsState>((ref) async {
      final api = ref.watch(mockApiServiceProvider);

      try {
        final payments = await api.getPayments();
        final complaints = await api.getComplaints();

        // Calculate monthly payments (mocking last 6 months)
        final List<double> monthly = [0, 0, 0, 0, 0, 0];
        double total = 0;
        for (var p in payments) {
          if (p.status == 'Paid') {
            total += p.amount;
            // Mocking distribution for chart
            int monthIndex = p.dueDate.month % 6;
            monthly[monthIndex] += p.amount;
          }
        }

        // Complaint stats
        final Map<String, int> stats = {'Open': 0, 'Resolved': 0, 'Pending': 0};
        int active = 0;
        for (var c in complaints) {
          stats[c.status] = (stats[c.status] ?? 0) + 1;
          if (c.status != 'Resolved') active++;
        }

        return TenantAnalyticsState(
          isLoading: false,
          monthlyPayments: monthly,
          complaintStats: stats,
          totalSpent: total,
          activeComplaints: active,
        );
      } catch (e) {
        return TenantAnalyticsState(isLoading: false);
      }
    });
