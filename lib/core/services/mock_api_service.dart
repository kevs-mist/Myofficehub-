import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../models/admin_model.dart';
import '../../models/car_model.dart';
import '../../models/tenant_model.dart';
import '../../models/event_model.dart';
import '../../models/payment_model.dart';
import '../../models/complaint_model.dart';
import '../../models/staff_model.dart';
import 'api_service.dart';

class MockApiService implements ApiService {
  static final MockApiService _instance = MockApiService._internal();
  factory MockApiService() => _instance;
  MockApiService._internal();

  static const _uuid = Uuid();

  static const String _kSeededKey = 'mock_seeded_v1';

  static const String _kAdminProfileKey = 'mock_admin_profile_v1';
  static const String _kTenantProfileKey = 'mock_tenant_profile_v1';

  static const String _kTenantsKey = 'mock_tenants_v1';
  static const String _kEventsKey = 'mock_events_v1';
  static const String _kPaymentsKey = 'mock_payments_v1';
  static const String _kComplaintsKey = 'mock_complaints_v1';
  static const String _kCarsKey = 'mock_cars_v1';
  static const String _kStaffKey = 'mock_staff_v1';

  // Mock Latency
  Future<void> _simulateLatency() async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  Future<SharedPreferences> _prefs() => SharedPreferences.getInstance();

  @override
  Future<void> initIfNeeded() async {
    final prefs = await _prefs();
    final seeded = prefs.getBool(_kSeededKey) ?? false;
    if (seeded) return;

    final defaultAdmin = AdminModel(
      id: 'admin_123',
      name: 'Rajesh Kumar',
      email: 'admin@skyline.com',
      phoneNumber: '+91 9876543210',
      officeComplexName: 'Skyline Business Park',
      maintenanceFee: 5000,
      parkingFee: 1500,
      lateFee: 250,
      upiId: 'skyline@upi',
      whatsappGroupNumber: '+91 9000000000',
    );

    final defaultTenants = <TenantModel>[
      TenantModel(
        id: 't1',
        name: 'TechFlow Solutions',
        officeNumber: 'A-101',
        email: 'contact@techflow.com',
        employeeCount: 12,
        vehicleCount: 4,
        status: 'Active',
      ),
      TenantModel(
        id: 't2',
        name: 'GreenLeaf Marketing',
        officeNumber: 'B-205',
        email: 'hello@greenleaf.com',
        employeeCount: 5,
        vehicleCount: 1,
        status: 'Active',
      ),
      TenantModel(
        id: 't3',
        name: 'InnovateX',
        officeNumber: 'C-304',
        email: 'info@innovatex.io',
        employeeCount: 25,
        vehicleCount: 10,
        status: 'Pending',
      ),
    ];

    final defaultCars = <CarModel>[
      CarModel(
        id: 'car_1',
        tenantName: 'TechFlow Solutions',
        officeNumber: 'A-101',
        licensePlateNumber: 'KA 01 AB 1234',
        parkingNumber: 'P-01',
      ),
      CarModel(
        id: 'car_2',
        tenantName: 'TechFlow Solutions',
        officeNumber: 'A-101',
        licensePlateNumber: 'KA 01 CD 5678',
        parkingNumber: 'P-02',
      ),
      CarModel(
        id: 'car_3',
        tenantName: 'GreenLeaf Marketing',
        officeNumber: 'B-205',
        licensePlateNumber: 'MH 12 XY 9999',
        parkingNumber: 'P-12',
      ),
    ];

    final defaultStaff = <StaffModel>[
      StaffModel(
        id: 's1',
        name: 'Ramesh Kumar',
        role: 'security',
        photoUrl: '',
        assignedOffices: const ['A-101', 'B-205'],
      ),
      StaffModel(
        id: 's2',
        name: 'Suresh Yadav',
        role: 'security',
        photoUrl: '',
        assignedOffices: const ['C-304'],
      ),
      StaffModel(
        id: 'h1',
        name: 'Anita Sharma',
        role: 'help',
        photoUrl: '',
        assignedOffices: const ['A-101'],
      ),
      StaffModel(
        id: 'h2',
        name: 'Meena Devi',
        role: 'help',
        photoUrl: '',
        assignedOffices: const ['B-205', 'C-304'],
      ),
    ];

    final now = DateTime.now();
    final defaultEvents = <EventModel>[
      EventModel(
        id: 'e1',
        title: 'Fire Safety Drill',
        date: now.add(const Duration(days: 2)),
        location: 'Building A, Lobby',
        description: 'Mandatory fire safety drill for all tenants.',
        minutesOfMeeting: '',
      ),
      EventModel(
        id: 'e2',
        title: 'Networking High Tea',
        date: now.add(const Duration(days: 5)),
        location: 'Cafeteria',
        description: 'Monthly networking event for office owners.',
        minutesOfMeeting: '',
      ),
    ];

    final defaultPayments = <PaymentModel>[
      PaymentModel(
        id: 'p1',
        tenantName: 'TechFlow Solutions',
        tenantId: 't1',
        amount: 5000,
        type: 'Maintenance',
        status: 'Pending',
        dueDate: now.subtract(const Duration(days: 2)),
      ),
      PaymentModel(
        id: 'p2',
        tenantName: 'TechFlow Solutions',
        tenantId: 't1',
        amount: 1500,
        type: 'Parking',
        status: 'Paid',
        dueDate: now.subtract(const Duration(days: 10)),
      ),
      PaymentModel(
        id: 'p3',
        tenantName: 'GreenLeaf Marketing',
        tenantId: 't2',
        amount: 5000,
        type: 'Maintenance',
        status: 'Overdue',
        dueDate: now.subtract(const Duration(days: 5)),
      ),
    ];

    final defaultComplaints = <ComplaintModel>[
      ComplaintModel(
        id: 'c1',
        tenantName: 'TechFlow Solutions',
        officeNumber: 'A-101',
        description: 'AC not cooling in master cabin.',
        timestamp: now.subtract(const Duration(hours: 4)),
        status: 'Open',
        type: 'personal',
      ),
      ComplaintModel(
        id: 'c2',
        tenantName: 'GreenLeaf Marketing',
        officeNumber: 'B-205',
        description: 'Water leakage in pantry area.',
        timestamp: now.subtract(const Duration(days: 1)),
        status: 'Resolved',
        type: 'personal',
      ),
    ];

    await prefs.setString(_kAdminProfileKey, jsonEncode(defaultAdmin.toJson()));
    await prefs.setString(
      _kTenantsKey,
      _encodeList(defaultTenants.map((e) => e.toJson()).toList()),
    );
    await prefs.setString(
      _kEventsKey,
      _encodeList(defaultEvents.map((e) => e.toJson()).toList()),
    );
    await prefs.setString(
      _kPaymentsKey,
      _encodeList(defaultPayments.map((e) => e.toJson()).toList()),
    );
    await prefs.setString(
      _kComplaintsKey,
      _encodeList(defaultComplaints.map((e) => e.toJson()).toList()),
    );
    await prefs.setString(
      _kCarsKey,
      _encodeList(defaultCars.map((e) => e.toJson()).toList()),
    );
    await prefs.setString(
      _kStaffKey,
      _encodeList(defaultStaff.map((e) => e.toJson()).toList()),
    );
    await prefs.setBool(_kSeededKey, true);
  }

  @override
  Future<void> resetForNewAccount({
    AdminModel? adminProfile,
    Map<String, dynamic>? tenantProfile,
  }) async {
    final prefs = await _prefs();
    await prefs.clear();
    if (adminProfile != null) await saveAdminProfile(adminProfile);
    if (tenantProfile != null) {
      await prefs.setString(_kTenantProfileKey, jsonEncode(tenantProfile));
    }
  }

  String _encodeList(List<Map<String, dynamic>> items) => jsonEncode(items);

  List<Map<String, dynamic>> _decodeList(String? raw) {
    if (raw == null || raw.isEmpty) return [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return [];
    return decoded
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  // --- Admin ---
  @override
  Future<AdminModel> getAdminProfile() async {
    await initIfNeeded();
    await _simulateLatency();
    final prefs = await _prefs();
    final raw = prefs.getString(_kAdminProfileKey);
    if (raw == null || raw.isEmpty) {
      throw StateError('Admin profile not found');
    }
    return AdminModel.fromJson(Map<String, dynamic>.from(jsonDecode(raw)));
  }

  @override
  Future<void> saveAdminProfile(AdminModel admin) async {
    await initIfNeeded();
    await _simulateLatency();
    final prefs = await _prefs();
    await prefs.setString(_kAdminProfileKey, jsonEncode(admin.toJson()));
  }

  @override
  Future<void> saveTenantProfile({
    required String companyName,
    required String accountHolderName,
    required String unitOrOffice,
    String? carLicensePlateNumber,
    String? parkingNumber,
  }) async {
    await initIfNeeded();
    await _simulateLatency();
    final prefs = await _prefs();

    final profile = {
      'companyName': companyName,
      'accountHolderName': accountHolderName,
      'unitOrOffice': unitOrOffice,
      'carLicensePlateNumber': carLicensePlateNumber,
      'parkingNumber': parkingNumber,
    };

    await prefs.setString(_kTenantProfileKey, jsonEncode(profile));

    // Also update the mock cars list for the admin view
    if (carLicensePlateNumber != null && carLicensePlateNumber.isNotEmpty) {
      final cars = await getCars();
      // Simple logic: update or add a car for this company
      bool found = false;
      final updatedCars = cars.map((c) {
        if (c.tenantName == companyName) {
          found = true;
          return CarModel(
            id: c.id,
            tenantName: companyName,
            officeNumber: unitOrOffice,
            licensePlateNumber: carLicensePlateNumber,
            parkingNumber: parkingNumber ?? c.parkingNumber,
          );
        }
        return c;
      }).toList();

      if (!found) {
        updatedCars.add(
          CarModel(
            id: _uuid.v4(),
            tenantName: companyName,
            officeNumber: unitOrOffice,
            licensePlateNumber: carLicensePlateNumber,
            parkingNumber: parkingNumber ?? 'N/A',
          ),
        );
      }
      await saveCars(updatedCars);
    }
  }

  @override
  Future<Map<String, dynamic>?> getTenantProfile() async {
    await initIfNeeded();
    await _simulateLatency();
    final prefs = await _prefs();
    final raw = prefs.getString(_kTenantProfileKey);
    if (raw == null || raw.isEmpty) return null;
    return Map<String, dynamic>.from(jsonDecode(raw));
  }

  // --- Tenants ---
  @override
  Future<List<TenantModel>> getTenants() async {
    await initIfNeeded();
    await _simulateLatency();
    final prefs = await _prefs();
    final decoded = _decodeList(prefs.getString(_kTenantsKey));
    return decoded.map(TenantModel.fromJson).toList();
  }

  Future<void> saveTenants(List<TenantModel> tenants) async {
    final prefs = await _prefs();
    await prefs.setString(
      _kTenantsKey,
      _encodeList(tenants.map((e) => e.toJson()).toList()),
    );
  }

  @override
  Future<void> inviteTenant(String email) async {
    await initIfNeeded();
    await _simulateLatency();
    final tenants = await getTenants();
    tenants.insert(
      0,
      TenantModel(
        id: _uuid.v4(),
        name: email.split('@').first,
        officeNumber: 'TBD',
        email: email,
        employeeCount: 0,
        vehicleCount: 0,
        status: 'Pending',
      ),
    );
    await saveTenants(tenants);
  }

  @override
  Future<TenantModel> addTenantManual({
    required String name,
    required String officeNumber,
    required String email,
    required int employeeCount,
    required int vehicleCount,
    String status = 'Active',
  }) async {
    await initIfNeeded();
    await _simulateLatency();
    final tenants = await getTenants();
    final tenant = TenantModel(
      id: _uuid.v4(),
      name: name,
      officeNumber: officeNumber,
      email: email,
      employeeCount: employeeCount,
      vehicleCount: vehicleCount,
      status: status,
    );
    tenants.insert(0, tenant);
    await saveTenants(tenants);
    return tenant;
  }

  // --- Events ---
  @override
  Future<List<EventModel>> getEvents() async {
    await initIfNeeded();
    await _simulateLatency();
    final prefs = await _prefs();
    final decoded = _decodeList(prefs.getString(_kEventsKey));
    return decoded.map(EventModel.fromJson).toList();
  }

  Future<void> saveEvents(List<EventModel> events) async {
    final prefs = await _prefs();
    await prefs.setString(
      _kEventsKey,
      _encodeList(events.map((e) => e.toJson()).toList()),
    );
  }

  @override
  Future<void> createEvent(EventModel event) async {
    await initIfNeeded();
    await _simulateLatency();
    final events = await getEvents();
    final withId = EventModel(
      id: event.id.isEmpty ? _uuid.v4() : event.id,
      title: event.title,
      date: event.date,
      location: event.location,
      description: event.description,
      minutesOfMeeting: event.minutesOfMeeting,
    );
    events.insert(0, withId);
    await saveEvents(events);
  }

  @override
  Future<void> updateEventMinutes({
    required String eventId,
    required String minutesOfMeeting,
  }) async {
    await initIfNeeded();
    await _simulateLatency();
    final events = await getEvents();
    final updated = events
        .map(
          (e) => e.id == eventId
              ? EventModel(
                  id: e.id,
                  title: e.title,
                  date: e.date,
                  location: e.location,
                  description: e.description,
                  minutesOfMeeting: minutesOfMeeting,
                )
              : e,
        )
        .toList();
    await saveEvents(updated);
  }

  // --- Payments ---
  @override
  Future<List<PaymentModel>> getPayments() async {
    await initIfNeeded();
    await _simulateLatency();
    final prefs = await _prefs();
    final decoded = _decodeList(prefs.getString(_kPaymentsKey));
    return decoded.map(PaymentModel.fromJson).toList();
  }

  // --- Complaints ---
  @override
  Future<List<ComplaintModel>> getComplaints() async {
    await initIfNeeded();
    await _simulateLatency();
    final prefs = await _prefs();
    final decoded = _decodeList(prefs.getString(_kComplaintsKey));
    return decoded.map(ComplaintModel.fromJson).toList();
  }

  Future<void> saveComplaints(List<ComplaintModel> complaints) async {
    final prefs = await _prefs();
    await prefs.setString(
      _kComplaintsKey,
      _encodeList(complaints.map((e) => e.toJson()).toList()),
    );
  }

  @override
  Future<void> submitComplaint(ComplaintModel complaint) async {
    await initIfNeeded();
    await _simulateLatency();
    final complaints = await getComplaints();
    final c = ComplaintModel(
      id: complaint.id.isEmpty ? _uuid.v4() : complaint.id,
      tenantName: complaint.tenantName,
      officeNumber: complaint.officeNumber,
      description: complaint.description,
      timestamp: complaint.timestamp,
      status: complaint.status,
      type: complaint.type,
    );
    complaints.insert(0, c);
    await saveComplaints(complaints);
  }

  @override
  Future<void> markComplaintResolved(String complaintId) async {
    await initIfNeeded();
    await _simulateLatency();
    final complaints = await getComplaints();
    final updated = complaints
        .map(
          (c) => c.id == complaintId
              ? ComplaintModel(
                  id: c.id,
                  tenantName: c.tenantName,
                  officeNumber: c.officeNumber,
                  description: c.description,
                  timestamp: c.timestamp,
                  status: 'Resolved',
                  type: c.type,
                )
              : c,
        )
        .toList();
    await saveComplaints(updated);
  }

  // --- Cars ---
  @override
  Future<List<CarModel>> getCars() async {
    await initIfNeeded();
    await _simulateLatency();
    final prefs = await _prefs();
    final decoded = _decodeList(prefs.getString(_kCarsKey));
    return decoded.map(CarModel.fromJson).toList();
  }

  Future<void> saveCars(List<CarModel> cars) async {
    final prefs = await _prefs();
    await prefs.setString(
      _kCarsKey,
      _encodeList(cars.map((e) => e.toJson()).toList()),
    );
  }

  // --- Staff ---
  @override
  Future<List<StaffModel>> getStaff() async {
    await initIfNeeded();
    await _simulateLatency();
    final prefs = await _prefs();
    final decoded = _decodeList(prefs.getString(_kStaffKey));
    return decoded.map(StaffModel.fromJson).toList();
  }

  Future<void> saveStaff(List<StaffModel> staff) async {
    final prefs = await _prefs();
    await prefs.setString(
      _kStaffKey,
      _encodeList(staff.map((e) => e.toJson()).toList()),
    );
  }

  // --- Staff ---
  @override
  Stream<List<EventModel>> get eventsStream => Stream.fromFuture(getEvents());
  @override
  Stream<List<ComplaintModel>> get complaintsStream =>
      Stream.fromFuture(getComplaints());
  @override
  Stream<List<PaymentModel>> get paymentsStream =>
      Stream.fromFuture(getPayments());
  @override
  Stream<List<TenantModel>> get tenantsStream =>
      Stream.fromFuture(getTenants());

  @override
  Future<int> getStaffCount() async {
    final staff = await getStaff();
    return staff.where((s) => s.role == 'security').length;
  }

  @override
  Future<void> updateFcmToken(String token) async {
    final prefs = await _prefs();
    await prefs.setString('fcm_token', token);
  }
}
