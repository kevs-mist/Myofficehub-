import 'package:supabase/supabase.dart';
import '../config/env.dart';

class ProductionSupabaseCrudService {
  static ProductionSupabaseCrudService? _instance;
  static ProductionSupabaseCrudService get instance =>
      _instance ??= ProductionSupabaseCrudService._();

  ProductionSupabaseCrudService._();

  late SupabaseClient _client;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    final url = Env.supabaseUrl.trim();
    final key = _apiKey;

    if (url.isEmpty) {
      throw Exception('SUPABASE_URL not set in environment');
    }
    if (key.isEmpty) {
      throw Exception(
          'SUPABASE_SERVICE_KEY (preferred) or SUPABASE_ANON_KEY not set');
    }

    _client = SupabaseClient(url, key);
    _initialized = true;
    print('✅ Production Supabase CRUD service initialized');
  }

  // --- Admin Settings ---
  Future<Map<String, dynamic>> getAdminSettings(String adminId) async {
    try {
      final existing = await _client
          .from('admin_settings')
          .select()
          .eq('admin_id', adminId)
          .maybeSingle();

      if (existing != null) {
        return existing;
      }

      final now = DateTime.now().toIso8601String();
      final created = await _client
          .from('admin_settings')
          .insert({
            'admin_id': adminId,
            'office_complex_name': 'Office Complex',
            'maintenance_fee': 0,
            'parking_fee': 0,
            'late_fee': 0,
            'upi_id': '',
            'whatsapp_group_number': '',
            'created_at': now,
            'updated_at': now,
          })
          .select()
          .single();

      return created;
    } catch (e) {
      return _handleSupabaseError(e, 'getAdminSettings');
    }
  }

  Future<Map<String, dynamic>> upsertAdminSettings({
    required String adminId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final now = DateTime.now().toIso8601String();
      final existing = await _client
          .from('admin_settings')
          .select('id')
          .eq('admin_id', adminId)
          .maybeSingle();

      final payload = <String, dynamic>{
        if (data['officeComplexName'] != null)
          'office_complex_name': data['officeComplexName'],
        if (data['office_complex_name'] != null)
          'office_complex_name': data['office_complex_name'],
        if (data['maintenanceFee'] != null)
          'maintenance_fee': data['maintenanceFee'],
        if (data['maintenance_fee'] != null)
          'maintenance_fee': data['maintenance_fee'],
        if (data['parkingFee'] != null) 'parking_fee': data['parkingFee'],
        if (data['parking_fee'] != null) 'parking_fee': data['parking_fee'],
        if (data['lateFee'] != null) 'late_fee': data['lateFee'],
        if (data['late_fee'] != null) 'late_fee': data['late_fee'],
        if (data['upiId'] != null) 'upi_id': data['upiId'],
        if (data['upi_id'] != null) 'upi_id': data['upi_id'],
        if (data['whatsappGroupNumber'] != null)
          'whatsapp_group_number': data['whatsappGroupNumber'],
        if (data['whatsapp_group_number'] != null)
          'whatsapp_group_number': data['whatsapp_group_number'],
        'updated_at': now,
      };

      if (existing != null) {
        final updated = await _client
            .from('admin_settings')
            .update(payload)
            .eq('admin_id', adminId)
            .select()
            .single();
        return updated;
      }

      payload['admin_id'] = adminId;
      payload['created_at'] = now;
      final created = await _client
          .from('admin_settings')
          .insert(payload)
          .select()
          .single();
      return created;
    } catch (e) {
      return _handleSupabaseError(e, 'upsertAdminSettings');
    }
  }

  // --- Tenant Profile (stored on tenants table) ---
  Future<Map<String, dynamic>> getTenantProfile(String tenantId) async {
    try {
      final tenant =
          await _client.from('tenants').select().eq('id', tenantId).single();
      return tenant;
    } catch (e) {
      return _handleSupabaseError(e, 'getTenantProfile');
    }
  }

  Future<Map<String, dynamic>> updateTenantProfile({
    required String tenantId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final payload = <String, dynamic>{
        if (data['companyName'] != null) 'company_name': data['companyName'],
        if (data['company_name'] != null) 'company_name': data['company_name'],
        if (data['accountHolderName'] != null)
          'account_holder_name': data['accountHolderName'],
        if (data['account_holder_name'] != null)
          'account_holder_name': data['account_holder_name'],
        if (data['unitOrOffice'] != null)
          'unit_or_office': data['unitOrOffice'],
        if (data['unit_or_office'] != null)
          'unit_or_office': data['unit_or_office'],
        if (data['carLicensePlateNumber'] != null)
          'car_license_plate_number': data['carLicensePlateNumber'],
        if (data['car_license_plate_number'] != null)
          'car_license_plate_number': data['car_license_plate_number'],
        if (data['parkingNumber'] != null)
          'parking_number': data['parkingNumber'],
        if (data['parking_number'] != null)
          'parking_number': data['parking_number'],
        if (data['phone'] != null) 'phone': data['phone'],
        'updated_at': DateTime.now().toIso8601String(),
      };

      final updated = await _client
          .from('tenants')
          .update(payload)
          .eq('id', tenantId)
          .select()
          .single();
      return updated;
    } catch (e) {
      return _handleSupabaseError(e, 'updateTenantProfile');
    }
  }

  // --- Event minutes ---
  Future<Map<String, dynamic>> updateEventMinutes({
    required String eventId,
    required String minutesOfMeeting,
  }) async {
    try {
      final updated = await _client
          .from('events')
          .update({
            'minutes_of_meeting': minutesOfMeeting,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', eventId)
          .select(
              '*, organizer:organizer_id(display_name, email), tenant:tenant_id(display_name, email)')
          .single();
      return updated;
    } catch (e) {
      return _handleSupabaseError(e, 'updateEventMinutes');
    }
  }

  // --- Complaint visibility ---
  Future<List<Map<String, dynamic>>> getVisibleComplaintsForTenant(
    String tenantId,
  ) async {
    try {
      final response = await _client
          .from('complaints')
          .select(
              '*, tenant:tenant_id(display_name, email), assigned:assigned_to(display_name, email)')
          .or('type.eq.general,tenant_id.eq.$tenantId')
          .order('created_at', ascending: false);

      return response;
    } catch (e) {
      return _handleSupabaseError(e, 'getVisibleComplaintsForTenant');
    }
  }

  // --- Payments with late-fee computation ---
  Future<List<Map<String, dynamic>>> getTenantPaymentsWithLateFee(
    String tenantId,
  ) async {
    try {
      // Fetch base payments
      final payments = await _client
          .from('payments')
          .select()
          .eq('tenant_id', tenantId)
          .order('created_at', ascending: false);

      // Fetch late fee (best effort)
      double lateFee = 0;
      try {
        final settings = await _client
            .from('admin_settings')
            .select('late_fee')
            .limit(1)
            .maybeSingle();
        if (settings != null && settings['late_fee'] != null) {
          lateFee = (settings['late_fee']).toDouble();
        }
      } catch (_) {}

      final now = DateTime.now();
      final computed = <Map<String, dynamic>>[];

      for (final raw in payments) {
        final p = Map<String, dynamic>.from(raw);
        final status = (p['status'] ?? '').toString().toLowerCase();

        DateTime? due;
        final dueRaw = p['due_date'];
        if (dueRaw is String && dueRaw.isNotEmpty) {
          due = DateTime.tryParse(dueRaw);
        }

        final isOverdue = status == 'overdue' ||
            (status != 'paid' && due != null && due.isBefore(now));

        final baseAmount =
            (p['amount'] is num) ? (p['amount']).toDouble() : 0.0;
        final lateFeeApplied = isOverdue ? lateFee : 0.0;
        p['base_amount'] = baseAmount;
        p['late_fee_applied'] = lateFeeApplied;
        p['total_amount'] = baseAmount + lateFeeApplied;

        computed.add(p);
      }

      return computed;
    } catch (e) {
      return _handleSupabaseError(e, 'getTenantPaymentsWithLateFee');
    }
  }

  // --- Cars ---
  Future<List<Map<String, dynamic>>> getCars() async {
    try {
      final response = await _client
          .from('cars')
          .select('*, tenant:tenant_id(display_name, email, office_number)')
          .order('created_at', ascending: false);
      return response;
    } catch (e) {
      return _handleSupabaseError(e, 'getCars');
    }
  }

  Future<Map<String, dynamic>> createCar(Map<String, dynamic> data) async {
    try {
      final payload = <String, dynamic>{
        'tenant_id': data['tenant_id'] ?? data['tenantId'],
        'license_plate_number':
            data['license_plate_number'] ?? data['licensePlateNumber'],
        'parking_number': data['parking_number'] ?? data['parkingNumber'],
        'created_at': data['created_at'] ?? DateTime.now().toIso8601String(),
      };

      final created =
          await _client.from('cars').insert(payload).select().single();
      return created;
    } catch (e) {
      return _handleSupabaseError(e, 'createCar');
    }
  }

  Future<void> deleteCar(String id) async {
    try {
      await _client.from('cars').delete().eq('id', id);
    } catch (e) {
      return _handleSupabaseError(e, 'deleteCar');
    }
  }

  // --- Staff ---
  Future<List<Map<String, dynamic>>> getStaff() async {
    try {
      final response = await _client
          .from('staff')
          .select()
          .order('created_at', ascending: false);
      return response;
    } catch (e) {
      return _handleSupabaseError(e, 'getStaff');
    }
  }

  Future<Map<String, dynamic>> createStaff(Map<String, dynamic> data) async {
    try {
      final payload = <String, dynamic>{
        'name': data['name'],
        'role': data['role'],
        'photo_url': data['photo_url'] ?? data['photoUrl'] ?? '',
        'assigned_offices': data['assigned_offices'] ?? data['assignedOffices'],
        'created_at': data['created_at'] ?? DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final created =
          await _client.from('staff').insert(payload).select().single();
      return created;
    } catch (e) {
      return _handleSupabaseError(e, 'createStaff');
    }
  }

  Future<Map<String, dynamic>> updateStaff(
      String id, Map<String, dynamic> data) async {
    try {
      final payload = <String, dynamic>{
        if (data['name'] != null) 'name': data['name'],
        if (data['role'] != null) 'role': data['role'],
        if (data['photo_url'] != null) 'photo_url': data['photo_url'],
        if (data['photoUrl'] != null) 'photo_url': data['photoUrl'],
        if (data['assigned_offices'] != null)
          'assigned_offices': data['assigned_offices'],
        if (data['assignedOffices'] != null)
          'assigned_offices': data['assignedOffices'],
        'updated_at': DateTime.now().toIso8601String(),
      };

      final updated = await _client
          .from('staff')
          .update(payload)
          .eq('id', id)
          .select()
          .single();
      return updated;
    } catch (e) {
      return _handleSupabaseError(e, 'updateStaff');
    }
  }

  Future<Map<String, dynamic>> upsertTenantFromFirebase({
    required String firebaseUid,
    required String? email,
    required String? displayName,
  }) async {
    try {
      if (email == null || email.isEmpty) {
        throw Exception('Firebase email is required to upsert tenant');
      }

      final now = DateTime.now().toIso8601String();

      // Prefer matching by firebase_uid if column exists, else fallback to email.
      // This assumes you add a `firebase_uid` column in the tenants table.
      final existing = await _client
          .from('tenants')
          .select()
          .eq('email', email)
          .maybeSingle();

      if (existing != null) {
        final updated = await _client
            .from('tenants')
            .update({
              'firebase_uid': firebaseUid,
              'display_name': displayName ??
                  existing['display_name'] ??
                  email.split('@').first,
              'updated_at': now,
            })
            .eq('id', existing['id'])
            .select()
            .single();

        return updated;
      }

      final created = await _client
          .from('tenants')
          .insert({
            'email': email,
            'firebase_uid': firebaseUid,
            'display_name': displayName ?? email.split('@').first,
            'role': 'tenant',
            'created_at': now,
            'updated_at': now,
            'is_active': true,
          })
          .select()
          .single();

      return created;
    } catch (e) {
      return _handleSupabaseError(e, 'upsertTenantFromFirebase');
    }
  }

  String get _apiKey {
    final serviceKey = Env.supabaseServiceKey.trim();
    if (serviceKey.isNotEmpty) return serviceKey;
    return Env.supabaseAnonKey.trim();
  }

  SupabaseClient get client {
    if (!_initialized) {
      throw Exception('Supabase not initialized. Call initialize() first.');
    }
    return _client;
  }

  // Helper method for error handling
  dynamic _handleSupabaseError(dynamic error, String operation) {
    print('❌ Supabase error during $operation: $error');

    // Extract meaningful error message
    String errorMessage = 'Operation failed';

    if (error is PostgrestException) {
      errorMessage = error.message;
      print('🔍 PostgrestException details: ${error.details}');
    } else if (error is Exception) {
      errorMessage = error.toString();
    }

    throw Exception(errorMessage);
  }

  // Tenants CRUD operations with enhanced error handling
  Future<List<Map<String, dynamic>>> getTenants() async {
    try {
      final response = await _client
          .from('tenants')
          .select()
          .order('created_at', ascending: false);

      print('📋 Retrieved ${response.length} tenants');
      return response;
    } catch (e) {
      return _handleSupabaseError(e, 'getTenants');
    }
  }

  Future<Map<String, dynamic>> getTenant(String id) async {
    try {
      final response =
          await _client.from('tenants').select().eq('id', id).single();

      print('👤 Retrieved tenant: $id');
      return response;
    } catch (e) {
      return _handleSupabaseError(e, 'getTenant');
    }
  }

  Future<Map<String, dynamic>> createTenant(
      Map<String, dynamic> tenantData) async {
    try {
      // Validate required fields
      if (tenantData['email'] == null || tenantData['display_name'] == null) {
        throw Exception('Email and display_name are required');
      }

      final response =
          await _client.from('tenants').insert(tenantData).select().single();

      print('✅ Created tenant: ${response['id']}');
      return response;
    } catch (e) {
      return _handleSupabaseError(e, 'createTenant');
    }
  }

  Future<Map<String, dynamic>> updateTenant(
      String id, Map<String, dynamic> tenantData) async {
    try {
      final response = await _client
          .from('tenants')
          .update(tenantData)
          .eq('id', id)
          .select()
          .single();

      print('✅ Updated tenant: $id');
      return response;
    } catch (e) {
      return _handleSupabaseError(e, 'updateTenant');
    }
  }

  Future<void> deleteTenant(String id) async {
    try {
      await _client.from('tenants').delete().eq('id', id);
      print('🗑️ Deleted tenant: $id');
    } catch (e) {
      return _handleSupabaseError(e, 'deleteTenant');
    }
  }

  // Events CRUD operations
  Future<List<Map<String, dynamic>>> getEvents() async {
    try {
      final response = await _client
          .from('events')
          .select(
              '*, organizer:organizer_id(display_name, email), tenant:tenant_id(display_name, email)')
          .order('created_at', ascending: false);

      print('📅 Retrieved ${response.length} events');
      return response;
    } catch (e) {
      return _handleSupabaseError(e, 'getEvents');
    }
  }

  Future<Map<String, dynamic>> getEvent(String id) async {
    try {
      final response = await _client
          .from('events')
          .select(
              '*, organizer:organizer_id(display_name, email), tenant:tenant_id(display_name, email)')
          .eq('id', id)
          .single();

      print('📅 Retrieved event: $id');
      return response;
    } catch (e) {
      return _handleSupabaseError(e, 'getEvent');
    }
  }

  Future<Map<String, dynamic>> createEvent(
      Map<String, dynamic> eventData) async {
    try {
      // Validate required fields
      if (eventData['title'] == null) {
        throw Exception('Event title is required');
      }

      final response = await _client
          .from('events')
          .insert(eventData)
          .select(
              '*, organizer:organizer_id(display_name, email), tenant:tenant_id(display_name, email)')
          .single();

      print('✅ Created event: ${response['id']}');
      return response;
    } catch (e) {
      return _handleSupabaseError(e, 'createEvent');
    }
  }

  Future<Map<String, dynamic>> updateEvent(
      String id, Map<String, dynamic> eventData) async {
    try {
      final response = await _client
          .from('events')
          .update(eventData)
          .eq('id', id)
          .select(
              '*, organizer:organizer_id(display_name, email), tenant:tenant_id(display_name, email)')
          .single();

      print('✅ Updated event: $id');
      return response;
    } catch (e) {
      return _handleSupabaseError(e, 'updateEvent');
    }
  }

  Future<void> deleteEvent(String id) async {
    try {
      await _client.from('events').delete().eq('id', id);
      print('🗑️ Deleted event: $id');
    } catch (e) {
      return _handleSupabaseError(e, 'deleteEvent');
    }
  }

  // Complaints CRUD operations
  Future<List<Map<String, dynamic>>> getComplaints() async {
    try {
      final response = await _client
          .from('complaints')
          .select(
              '*, tenant:tenant_id(display_name, email), assigned:assigned_to(display_name, email)')
          .order('created_at', ascending: false);

      print('📝 Retrieved ${response.length} complaints');
      return response;
    } catch (e) {
      return _handleSupabaseError(e, 'getComplaints');
    }
  }

  Future<Map<String, dynamic>> getComplaint(String id) async {
    try {
      final response = await _client
          .from('complaints')
          .select(
              '*, tenant:tenant_id(display_name, email), assigned:assigned_to(display_name, email)')
          .eq('id', id)
          .single();

      print('📝 Retrieved complaint: $id');
      return response;
    } catch (e) {
      return _handleSupabaseError(e, 'getComplaint');
    }
  }

  Future<Map<String, dynamic>> createComplaint(
      Map<String, dynamic> complaintData) async {
    try {
      // Validate required fields
      if (complaintData['title'] == null ||
          complaintData['description'] == null) {
        throw Exception('Complaint title and description are required');
      }

      final response = await _client
          .from('complaints')
          .insert(complaintData)
          .select(
              '*, tenant:tenant_id(display_name, email), assigned:assigned_to(display_name, email)')
          .single();

      print('✅ Created complaint: ${response['id']}');
      return response;
    } catch (e) {
      return _handleSupabaseError(e, 'createComplaint');
    }
  }

  Future<Map<String, dynamic>> updateComplaint(
      String id, Map<String, dynamic> complaintData) async {
    try {
      final response = await _client
          .from('complaints')
          .update(complaintData)
          .eq('id', id)
          .select(
              '*, tenant:tenant_id(display_name, email), assigned:assigned_to(display_name, email)')
          .single();

      print('✅ Updated complaint: $id');
      return response;
    } catch (e) {
      return _handleSupabaseError(e, 'updateComplaint');
    }
  }

  Future<void> deleteComplaint(String id) async {
    try {
      await _client.from('complaints').delete().eq('id', id);
      print('🗑️ Deleted complaint: $id');
    } catch (e) {
      return _handleSupabaseError(e, 'deleteComplaint');
    }
  }

  // Payments CRUD operations
  Future<List<Map<String, dynamic>>> getPayments() async {
    try {
      final response = await _client
          .from('payments')
          .select('*, tenant:tenant_id(display_name, email)')
          .order('created_at', ascending: false);

      print('💰 Retrieved ${response.length} payments');
      return response;
    } catch (e) {
      return _handleSupabaseError(e, 'getPayments');
    }
  }

  Future<Map<String, dynamic>> getPayment(String id) async {
    try {
      final response = await _client
          .from('payments')
          .select('*, tenant:tenant_id(display_name, email)')
          .eq('id', id)
          .single();

      print('💰 Retrieved payment: $id');
      return response;
    } catch (e) {
      return _handleSupabaseError(e, 'getPayment');
    }
  }

  Future<Map<String, dynamic>> createPayment(
      Map<String, dynamic> paymentData) async {
    try {
      // Validate required fields
      if (paymentData['amount'] == null || paymentData['tenant_id'] == null) {
        throw Exception('Payment amount and tenant_id are required');
      }

      final response = await _client
          .from('payments')
          .insert(paymentData)
          .select('*, tenant:tenant_id(display_name, email)')
          .single();

      print('✅ Created payment: ${response['id']}');
      return response;
    } catch (e) {
      return _handleSupabaseError(e, 'createPayment');
    }
  }

  Future<Map<String, dynamic>> updatePayment(
      String id, Map<String, dynamic> paymentData) async {
    try {
      final response = await _client
          .from('payments')
          .update(paymentData)
          .eq('id', id)
          .select('*, tenant:tenant_id(display_name, email)')
          .single();

      print('✅ Updated payment: $id');
      return response;
    } catch (e) {
      return _handleSupabaseError(e, 'updatePayment');
    }
  }

  Future<void> deletePayment(String id) async {
    try {
      await _client.from('payments').delete().eq('id', id);
      print('🗑️ Deleted payment: $id');
    } catch (e) {
      return _handleSupabaseError(e, 'deletePayment');
    }
  }

  // Get records by user ID (for tenant-specific data)
  Future<List<Map<String, dynamic>>> getTenantEvents(String tenantId) async {
    try {
      final response = await _client
          .from('events')
          .select('*, organizer:organizer_id(display_name, email)')
          .eq('tenant_id', tenantId)
          .order('created_at', ascending: false);

      print('📅 Retrieved ${response.length} events for tenant: $tenantId');
      return response;
    } catch (e) {
      return _handleSupabaseError(e, 'getTenantEvents');
    }
  }

  Future<List<Map<String, dynamic>>> getTenantComplaints(
      String tenantId) async {
    try {
      final response = await _client
          .from('complaints')
          .select('*, assigned:assigned_to(display_name, email)')
          .eq('tenant_id', tenantId)
          .order('created_at', ascending: false);

      print('📝 Retrieved ${response.length} complaints for tenant: $tenantId');
      return response;
    } catch (e) {
      return _handleSupabaseError(e, 'getTenantComplaints');
    }
  }

  Future<List<Map<String, dynamic>>> getTenantPayments(String tenantId) async {
    try {
      final response = await _client
          .from('payments')
          .select()
          .eq('tenant_id', tenantId)
          .order('created_at', ascending: false);

      print('💰 Retrieved ${response.length} payments for tenant: $tenantId');
      return response;
    } catch (e) {
      return _handleSupabaseError(e, 'getTenantPayments');
    }
  }

  // Advanced queries for statistics and reporting
  Future<Map<String, dynamic>> getTenantStatistics(String tenantId) async {
    try {
      final response = await _client
          .rpc('get_tenant_stats', params: {'tenant_uuid': tenantId});

      print('📊 Retrieved statistics for tenant: $tenantId');
      return response;
    } catch (e) {
      return _handleSupabaseError(e, 'getTenantStatistics');
    }
  }

  Future<List<Map<String, dynamic>>> getComplaintsByStatus(
      String status) async {
    try {
      final response = await _client
          .from('complaints')
          .select('*, tenant:tenant_id(display_name, email)')
          .eq('status', status)
          .order('created_at', ascending: false);

      print('📝 Retrieved ${response.length} complaints with status: $status');
      return response;
    } catch (e) {
      return _handleSupabaseError(e, 'getComplaintsByStatus');
    }
  }

  Future<List<Map<String, dynamic>>> getUpcomingEvents() async {
    try {
      final response = await _client
          .from('events')
          .select(
              '*, organizer:organizer_id(display_name, email), tenant:tenant_id(display_name, email)')
          .eq('is_active', true)
          .gte('event_date', DateTime.now().toIso8601String())
          .order('event_date', ascending: true)
          .limit(10);

      print('📅 Retrieved ${response.length} upcoming events');
      return response;
    } catch (e) {
      return _handleSupabaseError(e, 'getUpcomingEvents');
    }
  }

  // Health check method
  Future<Map<String, dynamic>> healthCheck() async {
    try {
      // Test basic connectivity
      await _client.from('tenants').select('count').limit(1);

      return {
        'status': 'healthy',
        'connected': true,
        'timestamp': DateTime.now().toIso8601String(),
        'test_query_successful': true,
      };
    } catch (e) {
      return {
        'status': 'unhealthy',
        'connected': false,
        'timestamp': DateTime.now().toIso8601String(),
        'error': e.toString(),
      };
    }
  }
}
