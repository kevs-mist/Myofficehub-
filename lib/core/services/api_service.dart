import '../../models/admin_model.dart';
import '../../models/car_model.dart';
import '../../models/complaint_model.dart';
import '../../models/event_model.dart';
import '../../models/payment_model.dart';
import '../../models/staff_model.dart';
import '../../models/tenant_model.dart';

abstract class ApiService {
  Future<void> initIfNeeded();

  Future<AdminModel> getAdminProfile();
  Future<void> saveAdminProfile(AdminModel admin);

  Future<void> saveTenantProfile({
    required String companyName,
    required String accountHolderName,
    required String unitOrOffice,
    String? carLicensePlateNumber,
    String? parkingNumber,
  });

  Future<Map<String, dynamic>?> getTenantProfile();

  Future<List<TenantModel>> getTenants();
  Future<void> inviteTenant(String email);

  Future<TenantModel> addTenantManual({
    required String name,
    required String officeNumber,
    required String email,
    required int employeeCount,
    required int vehicleCount,
    String status,
  });

  Future<List<EventModel>> getEvents();
  Future<void> createEvent(EventModel event);

  Future<void> updateEventMinutes({
    required String eventId,
    required String minutesOfMeeting,
  });

  Future<List<PaymentModel>> getPayments();

  Future<List<ComplaintModel>> getComplaints();
  Future<void> submitComplaint(ComplaintModel complaint);
  Future<void> markComplaintResolved(String complaintId);

  Future<List<CarModel>> getCars();
  Future<List<StaffModel>> getStaff();
  Future<int> getStaffCount();

  Future<void> resetForNewAccount({
    AdminModel? adminProfile,
    Map<String, dynamic>? tenantProfile,
  });

  Future<void> updateFcmToken(String token);

  // Real-time Streams
  Stream<List<EventModel>> get eventsStream;
  Stream<List<ComplaintModel>> get complaintsStream;
  Stream<List<PaymentModel>> get paymentsStream;
  Stream<List<TenantModel>> get tenantsStream;
}
