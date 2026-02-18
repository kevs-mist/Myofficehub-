import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/admin_model.dart';
import '../../models/car_model.dart';
import '../../models/complaint_model.dart';
import '../../models/event_model.dart';
import '../../models/payment_model.dart';
import '../../models/staff_model.dart';
import '../../models/tenant_model.dart';
import 'api_service.dart';
import 'backend_config.dart';

class ProductionApiService implements ApiService {
  ProductionApiService({
    FirebaseAuth? firebaseAuth,
    http.Client? client,
    String? baseUrl,
  }) : _auth = firebaseAuth ?? FirebaseAuth.instance,
       _client = client ?? http.Client(),
       _baseUrl = baseUrl ?? BackendConfig.baseUrl;

  final FirebaseAuth _auth;
  final http.Client _client;
  final String _baseUrl;

  bool _initialized = false;
  String? _cachedRole;
  String? _cachedTenantId;

  @override
  Future<void> initIfNeeded() async {
    if (_initialized) return;
    _initialized = true;
  }

  Future<String> _idToken() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('Not signed in');
    }
    final token = await user.getIdToken();
    if (token == null) {
      throw StateError('Could not get ID token');
    }
    return token;
  }

  Uri _u(String path) {
    final base = _baseUrl.endsWith('/')
        ? _baseUrl.substring(0, _baseUrl.length - 1)
        : _baseUrl;
    final p = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$base$p');
  }

  Future<Map<String, dynamic>> _requestJson(
    String method,
    String path, {
    Map<String, dynamic>? jsonBody,
    Map<String, String>? headers,
  }) async {
    final token = await _idToken();

    final reqHeaders = <String, String>{
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      if (headers != null) ...headers,
    };

    http.Response resp;
    final uri = _u(path);

    if (method == 'GET') {
      resp = await _client.get(uri, headers: reqHeaders);
    } else if (method == 'POST') {
      resp = await _client.post(
        uri,
        headers: {...reqHeaders, 'Content-Type': 'application/json'},
        body: jsonEncode(jsonBody ?? {}),
      );
    } else if (method == 'PATCH') {
      resp = await _client.patch(
        uri,
        headers: {...reqHeaders, 'Content-Type': 'application/json'},
        body: jsonEncode(jsonBody ?? {}),
      );
    } else if (method == 'PUT') {
      resp = await _client.put(
        uri,
        headers: {...reqHeaders, 'Content-Type': 'application/json'},
        body: jsonEncode(jsonBody ?? {}),
      );
    } else if (method == 'DELETE') {
      resp = await _client.delete(uri, headers: reqHeaders);
    } else {
      throw ArgumentError('Unsupported method $method');
    }

    final decoded = jsonDecode(resp.body.isEmpty ? '{}' : resp.body);
    if (decoded is! Map) {
      throw StateError('Unexpected response from server');
    }

    final map = Map<String, dynamic>.from(decoded);
    final success = map['success'] == true;
    if (!success) {
      throw StateError(map['message']?.toString() ?? 'Request failed');
    }

    final data = map['data'];
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    if (data is List) {
      return {'items': data};
    }
    return {'data': data};
  }

  Future<Map<String, dynamic>> _requestForm(
    String method,
    String path, {
    required Map<String, String> formBody,
  }) async {
    final token = await _idToken();
    final reqHeaders = <String, String>{
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Content-Type': 'application/x-www-form-urlencoded',
    };

    http.Response resp;
    final uri = _u(path);

    if (method == 'POST') {
      resp = await _client.post(uri, headers: reqHeaders, body: formBody);
    } else if (method == 'PUT') {
      resp = await _client.put(uri, headers: reqHeaders, body: formBody);
    } else {
      throw ArgumentError('Unsupported form method $method');
    }

    final decoded = jsonDecode(resp.body.isEmpty ? '{}' : resp.body);
    if (decoded is! Map) {
      throw StateError('Unexpected response from server');
    }

    final map = Map<String, dynamic>.from(decoded);
    final success = map['success'] == true;
    if (!success) {
      throw StateError(map['message']?.toString() ?? 'Request failed');
    }

    final data = map['data'];
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    if (data is List) {
      return {'items': data};
    }
    return {'data': data};
  }

  Future<void> _ensureMeCached() async {
    if (_cachedRole != null && _cachedTenantId != null) return;
    final me = await _requestJson('GET', '/auth/me');
    _cachedRole = me['role']?.toString();
    _cachedTenantId = me['tenantId']?.toString();
  }

  Map<String, dynamic> _tenantJsonForModel(Map<String, dynamic> raw) {
    return {
      'id': (raw['id'] ?? '').toString(),
      'name':
          (raw['name'] ??
                  raw['company_name'] ??
                  raw['display_name'] ??
                  raw['companyName'] ??
                  'Tenant')
              .toString(),
      'officeNumber':
          (raw['officeNumber'] ??
                  raw['office_number'] ??
                  raw['unit_or_office'] ??
                  raw['unitOrOffice'] ??
                  'TBD')
              .toString(),
      'email': (raw['email'] ?? '').toString(),
      'employeeCount': (raw['employeeCount'] ?? raw['employee_count'] ?? 0),
      'vehicleCount': (raw['vehicleCount'] ?? raw['vehicle_count'] ?? 0),
      'status': (raw['status'] ?? 'Active').toString(),
    };
  }

  Map<String, dynamic> _eventJsonForModel(Map<String, dynamic> raw) {
    return {
      'id': (raw['id'] ?? '').toString(),
      'title': (raw['title'] ?? '').toString(),
      'date':
          (raw['date'] ??
                  raw['event_date'] ??
                  raw['created_at'] ??
                  DateTime.now().toIso8601String())
              .toString(),
      'location': (raw['location'] ?? '').toString(),
      'description': (raw['description'] ?? '').toString(),
      'minutesOfMeeting':
          (raw['minutesOfMeeting'] ?? raw['minutes_of_meeting'] ?? '')
              .toString(),
    };
  }

  Map<String, dynamic> _complaintJsonForModel(Map<String, dynamic> raw) {
    final statusRaw = (raw['status'] ?? '').toString();
    final normalizedStatus = statusRaw.isEmpty
        ? 'Open'
        : statusRaw[0].toUpperCase() + statusRaw.substring(1);

    return {
      'id': (raw['id'] ?? '').toString(),
      'tenantName':
          (raw['tenantName'] ??
                  raw['tenant_name'] ??
                  raw['tenant']?['display_name'] ??
                  'Tenant')
              .toString(),
      'officeNumber':
          (raw['officeNumber'] ??
                  raw['office_number'] ??
                  raw['unit_or_office'] ??
                  'N/A')
              .toString(),
      'description': (raw['description'] ?? '').toString(),
      'timestamp':
          (raw['timestamp'] ??
                  raw['created_at'] ??
                  DateTime.now().toIso8601String())
              .toString(),
      'status': normalizedStatus,
      'type': (raw['type'] ?? 'personal').toString(),
    };
  }

  Map<String, dynamic> _paymentJsonForModel(Map<String, dynamic> raw) {
    final statusRaw = (raw['status'] ?? '').toString();
    final normalizedStatus = statusRaw.isEmpty
        ? 'Pending'
        : statusRaw[0].toUpperCase() + statusRaw.substring(1);

    return {
      'id': (raw['id'] ?? '').toString(),
      'tenantName':
          (raw['tenantName'] ??
                  raw['tenant_name'] ??
                  raw['tenant']?['display_name'] ??
                  'Tenant')
              .toString(),
      'tenantId': (raw['tenantId'] ?? raw['tenant_id'] ?? '').toString(),
      'amount': (raw['amount'] ?? raw['total_due'] ?? 0),
      'type': (raw['type'] ?? 'Maintenance').toString(),
      'status': normalizedStatus,
      'dueDate':
          (raw['dueDate'] ??
                  raw['due_date'] ??
                  raw['created_at'] ??
                  DateTime.now().toIso8601String())
              .toString(),
    };
  }

  @override
  Future<AdminModel> getAdminProfile() async {
    await initIfNeeded();
    final me = await _requestJson('GET', '/auth/me');
    final tenantId = me['tenantId']?.toString() ?? '';

    final adminSettings = me['adminSettings'] is Map
        ? Map<String, dynamic>.from(me['adminSettings'] as Map)
        : <String, dynamic>{};

    final officeName =
        (adminSettings['officeComplexName'] ??
                adminSettings['office_complex_name'] ??
                'Office Complex')
            .toString();
    final maintenanceFee =
        (adminSettings['maintenanceFee'] ??
                adminSettings['maintenance_fee'] ??
                0)
            as num;
    final parkingFee =
        (adminSettings['parkingFee'] ?? adminSettings['parking_fee'] ?? 0)
            as num;
    final lateFee =
        (adminSettings['lateFee'] ?? adminSettings['late_fee'] ?? 0) as num;
    final upiId = (adminSettings['upiId'] ?? adminSettings['upi_id'] ?? '')
        .toString();
    final whatsapp =
        (adminSettings['whatsappGroupNumber'] ??
                adminSettings['whatsapp_group_number'] ??
                '')
            .toString();

    return AdminModel(
      id: tenantId,
      name: (me['displayName'] ?? 'Admin').toString(),
      email: (me['email'] ?? '').toString(),
      phoneNumber: '',
      officeComplexName: officeName,
      maintenanceFee: maintenanceFee.toDouble(),
      parkingFee: parkingFee.toDouble(),
      lateFee: lateFee.toDouble(),
      upiId: upiId,
      whatsappGroupNumber: whatsapp,
    );
  }

  @override
  Future<void> saveAdminProfile(AdminModel admin) async {
    await initIfNeeded();
    await _requestJson(
      'PATCH',
      '/admin/profile',
      jsonBody: {
        'officeComplexName': admin.officeComplexName,
        'maintenanceFee': admin.maintenanceFee,
        'parkingFee': admin.parkingFee,
        'lateFee': admin.lateFee,
        'upiId': admin.upiId,
        'whatsappGroupNumber': admin.whatsappGroupNumber,
      },
    );
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
    await _requestJson(
      'PATCH',
      '/tenant/profile',
      jsonBody: {
        'companyName': companyName,
        'accountHolderName': accountHolderName,
        'unitOrOffice': unitOrOffice,
        'carLicensePlateNumber': carLicensePlateNumber,
        'parkingNumber': parkingNumber,
      },
    );
  }

  @override
  Future<Map<String, dynamic>?> getTenantProfile() async {
    await initIfNeeded();
    final raw = await _requestJson('GET', '/tenant/profile');

    return {
      'companyName':
          (raw['companyName'] ?? raw['company_name'] ?? 'My Workspace')
              .toString(),
      'accountHolderName':
          (raw['accountHolderName'] ?? raw['account_holder_name'] ?? 'Tenant')
              .toString(),
      'unitOrOffice': (raw['unitOrOffice'] ?? raw['unit_or_office'] ?? 'N/A')
          .toString(),
      'carLicensePlateNumber':
          (raw['carLicensePlateNumber'] ??
                  raw['car_license_plate_number'] ??
                  'N/A')
              .toString(),
      'parkingNumber': (raw['parkingNumber'] ?? raw['parking_number'] ?? 'N/A')
          .toString(),
    };
  }

  @override
  Future<List<TenantModel>> getTenants() async {
    await initIfNeeded();
    final resp = await _requestJson('GET', '/tenants');
    final items = (resp['items'] as List?) ?? const [];
    return items
        .whereType<Map>()
        .map(
          (e) => TenantModel.fromJson(
            _tenantJsonForModel(Map<String, dynamic>.from(e)),
          ),
        )
        .toList();
  }

  @override
  Future<void> inviteTenant(String email) async {
    await initIfNeeded();
    // Backend currently does not have an invite endpoint; create a pending tenant.
    await addTenantManual(
      name: email.split('@').first,
      officeNumber: 'TBD',
      email: email,
      employeeCount: 0,
      vehicleCount: 0,
      status: 'Pending',
    );
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

    final created = await _requestForm(
      'POST',
      '/tenants',
      formBody: {
        'name': name,
        'officeNumber': officeNumber,
        'email': email,
        'employeeCount': employeeCount.toString(),
        'vehicleCount': vehicleCount.toString(),
        'status': status,
      },
    );

    return TenantModel.fromJson(_tenantJsonForModel(created));
  }

  @override
  Future<List<EventModel>> getEvents() async {
    await initIfNeeded();
    final resp = await _requestJson('GET', '/events');
    final items = (resp['items'] as List?) ?? const [];
    return items
        .whereType<Map>()
        .map(
          (e) => EventModel.fromJson(
            _eventJsonForModel(Map<String, dynamic>.from(e)),
          ),
        )
        .toList();
  }

  @override
  Future<void> createEvent(EventModel event) async {
    await initIfNeeded();
    await _requestForm(
      'POST',
      '/events',
      formBody: {
        'title': event.title,
        'location': event.location,
        'description': event.description,
        'date': event.date.toIso8601String(),
      },
    );
  }

  @override
  Future<void> updateEventMinutes({
    required String eventId,
    required String minutesOfMeeting,
  }) async {
    await initIfNeeded();
    await _requestJson(
      'PATCH',
      '/admin/events/$eventId/minutes',
      jsonBody: {'minutesOfMeeting': minutesOfMeeting},
    );
  }

  @override
  Future<List<PaymentModel>> getPayments() async {
    await initIfNeeded();
    await _ensureMeCached();

    final path = _cachedRole == 'admin' ? '/payments' : '/tenant/payments';
    final resp = await _requestJson('GET', path);
    final items = (resp['items'] as List?) ?? const [];

    return items
        .whereType<Map>()
        .map(
          (e) => PaymentModel.fromJson(
            _paymentJsonForModel(Map<String, dynamic>.from(e)),
          ),
        )
        .toList();
  }

  @override
  Future<List<ComplaintModel>> getComplaints() async {
    await initIfNeeded();
    final resp = await _requestJson('GET', '/complaints');
    final items = (resp['items'] as List?) ?? const [];
    return items
        .whereType<Map>()
        .map(
          (e) => ComplaintModel.fromJson(
            _complaintJsonForModel(Map<String, dynamic>.from(e)),
          ),
        )
        .toList();
  }

  @override
  Future<void> submitComplaint(ComplaintModel complaint) async {
    await initIfNeeded();
    await _requestJson(
      'POST',
      '/tenant/complaints',
      jsonBody: {'description': complaint.description, 'type': complaint.type},
    );
  }

  @override
  Future<void> markComplaintResolved(String complaintId) async {
    await initIfNeeded();
    await _requestForm(
      'PUT',
      '/complaints/$complaintId',
      formBody: {'status': 'Resolved'},
    );
  }

  @override
  Future<List<CarModel>> getCars() async {
    await initIfNeeded();
    final resp = await _requestJson('GET', '/admin/cars');
    final items = (resp['items'] as List?) ?? const [];
    return items.whereType<Map>().map((e) {
      final raw = Map<String, dynamic>.from(e);
      return CarModel.fromJson({
        'id': (raw['id'] ?? '').toString(),
        'tenantName':
            (raw['tenantName'] ??
                    raw['tenant_name'] ??
                    raw['tenant']?['display_name'] ??
                    'Tenant')
                .toString(),
        'officeNumber':
            (raw['officeNumber'] ??
                    raw['office_number'] ??
                    raw['unit_or_office'] ??
                    'N/A')
                .toString(),
        'licensePlateNumber':
            (raw['licensePlateNumber'] ?? raw['license_plate_number'] ?? '')
                .toString(),
        'parkingNumber': (raw['parkingNumber'] ?? raw['parking_number'] ?? '')
            .toString(),
      });
    }).toList();
  }

  @override
  Future<List<StaffModel>> getStaff() async {
    await initIfNeeded();
    final resp = await _requestJson('GET', '/admin/staff');
    final items = (resp['items'] as List?) ?? const [];
    return items.whereType<Map>().map((e) {
      final raw = Map<String, dynamic>.from(e);
      return StaffModel.fromJson({
        'id': (raw['id'] ?? '').toString(),
        'name': (raw['name'] ?? '').toString(),
        'role': (raw['role'] ?? 'security').toString(),
        'photoUrl': (raw['photoUrl'] ?? raw['photo_url'] ?? '').toString(),
        'assignedOffices':
            raw['assignedOffices'] ?? raw['assigned_offices'] ?? const [],
      });
    }).toList();
  }

  @override
  Future<void> resetForNewAccount({
    AdminModel? adminProfile,
    Map<String, dynamic>? tenantProfile,
  }) async {
    await initIfNeeded();

    // Production backend stores data in Supabase; no local reset.
    if (adminProfile != null) {
      await saveAdminProfile(adminProfile);
      return;
    }

    if (tenantProfile != null) {
      await _requestJson('PATCH', '/tenant/profile', jsonBody: tenantProfile);
      return;
    }
  }

  @override
  Future<int> getStaffCount() async {
    await initIfNeeded();
    final staff = await getStaff();
    return staff.where((s) => s.role == 'security').length;
  }

  // --- Real-time Streams (Supabase) ---
  @override
  Stream<List<EventModel>> get eventsStream {
    return _uStream(
      'events',
      (data) => _eventJsonForModel(data),
      (json) => EventModel.fromJson(json),
    );
  }

  @override
  Stream<List<ComplaintModel>> get complaintsStream {
    return _uStream(
      'complaints',
      (data) => _complaintJsonForModel(data),
      (json) => ComplaintModel.fromJson(json),
    );
  }

  @override
  Stream<List<PaymentModel>> get paymentsStream {
    return _uStream(
      'payments',
      (data) => _paymentJsonForModel(data),
      (json) => PaymentModel.fromJson(json),
    );
  }

  @override
  Stream<List<TenantModel>> get tenantsStream {
    return _uStream(
      'tenants',
      (data) => _tenantJsonForModel(data),
      (json) => TenantModel.fromJson(json),
    );
  }

  /// Helper to create a unified real-time stream from Supabase
  Stream<List<T>> _uStream<T>(
    String table,
    Map<String, dynamic> Function(Map<String, dynamic>) mapper,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    // Return the stream directly from Supabase for real-time updates
    return Supabase.instance.client
        .from(table)
        .stream(primaryKey: ['id'])
        .map((list) => list.map((item) => fromJson(mapper(item))).toList());
  }

  @override
  Future<void> updateFcmToken(String token) async {
    await initIfNeeded();
    await _requestJson(
      'PATCH',
      '/tenant/profile',
      jsonBody: {'fcm_token': token},
    );
  }
}
