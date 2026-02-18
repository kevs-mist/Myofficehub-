import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/api_service.dart';
import '../core/services/backend_config.dart';
import '../core/services/mock_api_service.dart';
import '../core/services/production_api_service.dart';
import '../models/car_model.dart';
import '../models/complaint_model.dart';
import '../models/event_model.dart';
import '../models/admin_model.dart';
import '../models/staff_model.dart';
import '../models/tenant_model.dart';
import '../models/payment_model.dart';

final mockApiServiceProvider = Provider<ApiService>((ref) {
  if (BackendConfig.useMockApi) {
    return MockApiService();
  }
  return ProductionApiService();
});

final adminProfileProvider = FutureProvider<AdminModel>((ref) async {
  final api = ref.watch(mockApiServiceProvider);
  return api.getAdminProfile();
});

class TenantsNotifier extends AsyncNotifier<List<TenantModel>> {
  StreamSubscription? _subscription;

  @override
  Future<List<TenantModel>> build() async {
    final api = ref.watch(mockApiServiceProvider);

    _subscription?.cancel();
    _subscription = api.tenantsStream.listen((data) {
      if (!state.isLoading) {
        state = AsyncValue.data(data);
      }
    });

    return api.getTenants();
  }

  Future<void> inviteTenant(String email) async {
    final api = ref.read(mockApiServiceProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await api.inviteTenant(email);
      return api.getTenants();
    });
  }

  Future<void> addTenantManual({
    required String name,
    required String officeNumber,
    required String email,
    required int employeeCount,
    required int vehicleCount,
  }) async {
    final api = ref.read(mockApiServiceProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await api.addTenantManual(
        name: name,
        officeNumber: officeNumber,
        email: email,
        employeeCount: employeeCount,
        vehicleCount: vehicleCount,
      );
      return api.getTenants();
    });
  }
}

final tenantsProvider =
    AsyncNotifierProvider<TenantsNotifier, List<TenantModel>>(
      () => TenantsNotifier(),
    );

class EventsNotifier extends AsyncNotifier<List<EventModel>> {
  StreamSubscription? _subscription;

  @override
  Future<List<EventModel>> build() async {
    final api = ref.watch(mockApiServiceProvider);

    _subscription?.cancel();
    _subscription = api.eventsStream.listen((data) {
      if (!state.isLoading) {
        state = AsyncValue.data(data);
      }
    });

    return api.getEvents();
  }

  Future<void> createEvent({
    required String title,
    required String location,
    required String description,
    DateTime? date,
  }) async {
    final api = ref.read(mockApiServiceProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await api.createEvent(
        EventModel(
          id: '',
          title: title,
          date: date ?? DateTime.now().add(const Duration(days: 1)),
          location: location,
          description: description,
          minutesOfMeeting: '',
        ),
      );
      return api.getEvents();
    });
  }

  Future<void> updateEventMinutes({
    required String eventId,
    required String minutesOfMeeting,
  }) async {
    final api = ref.read(mockApiServiceProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await api.updateEventMinutes(
        eventId: eventId,
        minutesOfMeeting: minutesOfMeeting,
      );
      return api.getEvents();
    });
  }
}

final eventsProvider = AsyncNotifierProvider<EventsNotifier, List<EventModel>>(
  () => EventsNotifier(),
);

class ComplaintsNotifier extends AsyncNotifier<List<ComplaintModel>> {
  StreamSubscription? _subscription;

  @override
  Future<List<ComplaintModel>> build() async {
    final api = ref.watch(mockApiServiceProvider);

    _subscription?.cancel();
    _subscription = api.complaintsStream.listen((data) {
      if (!state.isLoading) {
        state = AsyncValue.data(data);
      }
    });

    return api.getComplaints();
  }

  Future<void> submitComplaint({
    required String tenantName,
    required String officeNumber,
    required String description,
    required String type,
  }) async {
    final api = ref.read(mockApiServiceProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await api.submitComplaint(
        ComplaintModel(
          id: '',
          tenantName: tenantName,
          officeNumber: officeNumber,
          description: description,
          timestamp: DateTime.now(),
          status: 'Open',
          type: type,
        ),
      );
      return api.getComplaints();
    });
  }

  Future<void> markResolved(String complaintId) async {
    final api = ref.read(mockApiServiceProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await api.markComplaintResolved(complaintId);
      return api.getComplaints();
    });
  }
}

final complaintsProvider =
    AsyncNotifierProvider<ComplaintsNotifier, List<ComplaintModel>>(
      () => ComplaintsNotifier(),
    );

class PaymentsNotifier extends AsyncNotifier<List<PaymentModel>> {
  StreamSubscription? _subscription;

  @override
  Future<List<PaymentModel>> build() async {
    final api = ref.watch(mockApiServiceProvider);

    _subscription?.cancel();
    _subscription = api.paymentsStream.listen((data) {
      if (!state.isLoading) {
        state = AsyncValue.data(data);
      }
    });

    return api.getPayments();
  }
}

final paymentsProvider =
    AsyncNotifierProvider<PaymentsNotifier, List<PaymentModel>>(
      () => PaymentsNotifier(),
    );

final carsProvider = FutureProvider<List<CarModel>>((ref) async {
  final api = ref.watch(mockApiServiceProvider);
  return api.getCars();
});

final staffProvider = FutureProvider<List<StaffModel>>((ref) async {
  final api = ref.watch(mockApiServiceProvider);
  return api.getStaff();
});
