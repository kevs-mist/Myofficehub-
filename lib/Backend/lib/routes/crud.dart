import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/supabase_crud_service_production.dart';
import '../services/validation_service.dart';
import '../utils/response.dart';
import '../middleware/auth_middleware.dart';

/// CRUD routes for Supabase operations
Router crudRoutes() {
  final router = Router();

  // Tenants CRUD
  router.get('/tenants', (Request request) async {
    try {
      final tenants = await ProductionSupabaseCrudService.instance.getTenants();
      return ResponseHelper.ok(tenants);
    } catch (e) {
      return ResponseHelper.internalServerError(e.toString());
    }
  });

  // --- Admin Profile / Settings ---
  router.get(
    '/admin/profile',
    (Request request) async {
      try {
        final tenantId = getCurrentTenantId(request);
        if (tenantId == null) {
          return ResponseHelper.unauthorized('User not authenticated');
        }

        if (!isAdmin(request)) {
          return ResponseHelper.forbidden('Admin access required');
        }

        final settings = await ProductionSupabaseCrudService.instance
            .getAdminSettings(tenantId);
        return ResponseHelper.ok(settings);
      } catch (e) {
        return ResponseHelper.internalServerError(e.toString());
      }
    },
  );

  router.patch(
    '/admin/profile',
    (Request request) async {
      try {
        final tenantId = getCurrentTenantId(request);
        if (tenantId == null) {
          return ResponseHelper.unauthorized('User not authenticated');
        }
        if (!isAdmin(request)) {
          return ResponseHelper.forbidden('Admin access required');
        }

        final body = await request.readAsString();
        final data = _parseJsonOrFormData(body);
        data['updated_at'] = DateTime.now().toIso8601String();

        final updated = await ProductionSupabaseCrudService.instance
            .upsertAdminSettings(adminId: tenantId, data: data);
        return ResponseHelper.ok(updated);
      } catch (e) {
        return ResponseHelper.internalServerError(e.toString());
      }
    },
  );

  // --- Tenant Profile ---
  router.get('/tenant/profile', (Request request) async {
    try {
      final tenantId = getCurrentTenantId(request);
      if (tenantId == null) {
        return ResponseHelper.unauthorized('User not authenticated');
      }
      final profile =
          await ProductionSupabaseCrudService.instance.getTenantProfile(tenantId);
      return ResponseHelper.ok(profile);
    } catch (e) {
      return ResponseHelper.internalServerError(e.toString());
    }
  });

  router.patch('/tenant/profile', (Request request) async {
    try {
      final tenantId = getCurrentTenantId(request);
      if (tenantId == null) {
        return ResponseHelper.unauthorized('User not authenticated');
      }

      final body = await request.readAsString();
      final data = _parseJsonOrFormData(body);
      data['updated_at'] = DateTime.now().toIso8601String();

      final updated = await ProductionSupabaseCrudService.instance
          .updateTenantProfile(tenantId: tenantId, data: data);
      return ResponseHelper.ok(updated);
    } catch (e) {
      return ResponseHelper.internalServerError(e.toString());
    }
  });

  router.get('/tenants/<id>', (Request request, String id) async {
    try {
      final tenant = await ProductionSupabaseCrudService.instance.getTenant(id);
      return ResponseHelper.ok(tenant);
    } catch (e) {
      return ResponseHelper.notFound('Tenant not found');
    }
  });

  router.post('/tenants', (Request request) async {
    try {
      final body = await request.readAsString();
      final data = _parseFormData(body);
      
      // Validate input
      final validationErrors = ValidationService.instance.validateTenant(data);
      if (validationErrors.isNotEmpty) {
        return ResponseHelper.badRequest('Validation failed', errors: validationErrors);
      }
      
      // Sanitize input
      final sanitizedData = ValidationService.instance.sanitizeData(data);
      
      // Add created_at and updated_at timestamps
      sanitizedData['created_at'] = DateTime.now().toIso8601String();
      sanitizedData['updated_at'] = DateTime.now().toIso8601String();
      
      final tenant = await ProductionSupabaseCrudService.instance.createTenant(sanitizedData);
      return ResponseHelper.created(tenant);
    } catch (e) {
      return ResponseHelper.internalServerError(e.toString());
    }
  });

  router.put('/tenants/<id>', (Request request, String id) async {
    try {
      final body = await request.readAsString();
      final data = _parseFormData(body);
      
      // Validate input
      final validationErrors = ValidationService.instance.validateTenant(data);
      if (validationErrors.isNotEmpty) {
        return ResponseHelper.badRequest('Validation failed', errors: validationErrors);
      }
      
      // Sanitize input
      final sanitizedData = ValidationService.instance.sanitizeData(data);
      
      // Update timestamp
      sanitizedData['updated_at'] = DateTime.now().toIso8601String();
      
      final tenant = await ProductionSupabaseCrudService.instance.updateTenant(id, sanitizedData);
      return ResponseHelper.ok(tenant);
    } catch (e) {
      return ResponseHelper.internalServerError(e.toString());
    }
  });

  router.delete('/tenants/<id>', (Request request, String id) async {
    try {
      await ProductionSupabaseCrudService.instance.deleteTenant(id);
      return ResponseHelper.ok({'message': 'Tenant deleted successfully'});
    } catch (e) {
      return ResponseHelper.internalServerError(e.toString());
    }
  });

  // Events CRUD
  router.get('/events', (Request request) async {
    try {
      final events = await ProductionSupabaseCrudService.instance.getEvents();
      return ResponseHelper.ok(events);
    } catch (e) {
      return ResponseHelper.internalServerError(e.toString());
    }
  });

  router.get('/events/<id>', (Request request, String id) async {
    try {
      final event = await ProductionSupabaseCrudService.instance.getEvent(id);
      return ResponseHelper.ok(event);
    } catch (e) {
      return ResponseHelper.notFound('Event not found');
    }
  });

  router.post('/events', (Request request) async {
    try {
      final body = await request.readAsString();
      final data = _parseFormData(body);
      
      // Validate input
      final validationErrors = ValidationService.instance.validateEvent(data);
      if (validationErrors.isNotEmpty) {
        return ResponseHelper.badRequest('Validation failed', errors: validationErrors);
      }
      
      // Sanitize input
      final sanitizedData = ValidationService.instance.sanitizeData(data);
      
      // Add created_at and updated_at timestamps
      sanitizedData['created_at'] = DateTime.now().toIso8601String();
      sanitizedData['updated_at'] = DateTime.now().toIso8601String();
      
      final event = await ProductionSupabaseCrudService.instance.createEvent(sanitizedData);
      return ResponseHelper.created(event);
    } catch (e) {
      return ResponseHelper.internalServerError(e.toString());
    }
  });

  router.put('/events/<id>', (Request request, String id) async {
    try {
      final body = await request.readAsString();
      final data = _parseFormData(body);
      
      // Update timestamp
      data['updated_at'] = DateTime.now().toIso8601String();
      
      final sanitizedData = ValidationService.instance.sanitizeData(data);
      
      final event = await ProductionSupabaseCrudService.instance.updateEvent(id, sanitizedData);
      return ResponseHelper.ok(event);
    } catch (e) {
      return ResponseHelper.internalServerError(e.toString());
    }
  });

  router.delete('/events/<id>', (Request request, String id) async {
    try {
      await ProductionSupabaseCrudService.instance.deleteEvent(id);
      return ResponseHelper.ok({'message': 'Event deleted successfully'});
    } catch (e) {
      return ResponseHelper.internalServerError(e.toString());
    }
  });

  router.patch('/admin/events/<id>/minutes', (Request request, String id) async {
    try {
      if (!isAdmin(request)) {
        return ResponseHelper.forbidden('Admin access required');
      }

      final body = await request.readAsString();
      final data = _parseJsonOrFormData(body);
      final minutes =
          (data['minutesOfMeeting'] ?? data['minutes_of_meeting'])?.toString();
      if (minutes == null) {
        return ResponseHelper.badRequest('minutesOfMeeting is required');
      }

      final updated = await ProductionSupabaseCrudService.instance
          .updateEventMinutes(eventId: id, minutesOfMeeting: minutes);
      return ResponseHelper.ok(updated);
    } catch (e) {
      return ResponseHelper.internalServerError(e.toString());
    }
  });

  // Complaints CRUD
  router.get('/complaints', (Request request) async {
    try {
      final role = getCurrentUserRole(request);
      final tenantId = getCurrentTenantId(request);
      if (role == null || tenantId == null) {
        return ResponseHelper.unauthorized('User not authenticated');
      }

      final complaints = role == 'admin'
          ? await ProductionSupabaseCrudService.instance.getComplaints()
          : await ProductionSupabaseCrudService.instance
              .getVisibleComplaintsForTenant(tenantId);
      return ResponseHelper.ok(complaints);
    } catch (e) {
      return ResponseHelper.internalServerError(e.toString());
    }
  });

  router.get('/complaints/<id>', (Request request, String id) async {
    try {
      final complaint = await ProductionSupabaseCrudService.instance.getComplaint(id);
      return ResponseHelper.ok(complaint);
    } catch (e) {
      return ResponseHelper.notFound('Complaint not found');
    }
  });

  router.post('/complaints', (Request request) async {
    try {
      final body = await request.readAsString();
      final data = _parseFormData(body);
      
      // Validate input
      final validationErrors = ValidationService.instance.validateComplaint(data);
      if (validationErrors.isNotEmpty) {
        return ResponseHelper.badRequest('Validation failed', errors: validationErrors);
      }
      
      // Sanitize input
      final sanitizedData = ValidationService.instance.sanitizeData(data);
      
      // Add created_at and updated_at timestamps
      sanitizedData['created_at'] = DateTime.now().toIso8601String();
      sanitizedData['updated_at'] = DateTime.now().toIso8601String();
      
      final complaint = await ProductionSupabaseCrudService.instance.createComplaint(sanitizedData);
      return ResponseHelper.created(complaint);
    } catch (e) {
      return ResponseHelper.internalServerError(e.toString());
    }
  });

  router.post('/tenant/complaints', (Request request) async {
    try {
      final tenantId = getCurrentTenantId(request);
      if (tenantId == null) {
        return ResponseHelper.unauthorized('User not authenticated');
      }

      final body = await request.readAsString();
      final data = _parseJsonOrFormData(body);

      final description = (data['description'] ?? '').toString().trim();
      final type = (data['type'] ?? 'personal').toString().trim();

      if (description.isEmpty) {
        return ResponseHelper.badRequest('description is required');
      }

      final now = DateTime.now().toIso8601String();
      final payload = <String, dynamic>{
        // These columns exist in your DATABASE_SCHEMA.md
        'title': 'Tenant Complaint',
        'description': description,
        'tenant_id': tenantId,
        // Map app type into a DB column named `type` (add this column in schema)
        'type': type,
        'status': 'open',
        'created_at': now,
        'updated_at': now,
      };

      final complaint =
          await ProductionSupabaseCrudService.instance.createComplaint(payload);
      return ResponseHelper.created(complaint);
    } catch (e) {
      return ResponseHelper.internalServerError(e.toString());
    }
  });

  router.put('/complaints/<id>', (Request request, String id) async {
    try {
      final body = await request.readAsString();
      final data = _parseFormData(body);
      
      // Update timestamp
      data['updated_at'] = DateTime.now().toIso8601String();
      
      final sanitizedData = ValidationService.instance.sanitizeData(data);
      
      final complaint = await ProductionSupabaseCrudService.instance.updateComplaint(id, sanitizedData);
      return ResponseHelper.ok(complaint);
    } catch (e) {
      return ResponseHelper.internalServerError(e.toString());
    }
  });

  router.delete('/complaints/<id>', (Request request, String id) async {
    try {
      await ProductionSupabaseCrudService.instance.deleteComplaint(id);
      return ResponseHelper.ok({'message': 'Complaint deleted successfully'});
    } catch (e) {
      return ResponseHelper.internalServerError(e.toString());
    }
  });

  // Payments CRUD
  router.get('/payments', (Request request) async {
    try {
      if (!isAdmin(request)) {
        return ResponseHelper.forbidden('Admin access required');
      }
      final payments = await ProductionSupabaseCrudService.instance.getPayments();
      return ResponseHelper.ok(payments);
    } catch (e) {
      return ResponseHelper.internalServerError(e.toString());
    }
  });

  router.get('/payments/<id>', (Request request, String id) async {
    try {
      final payment = await ProductionSupabaseCrudService.instance.getPayment(id);
      return ResponseHelper.ok(payment);
    } catch (e) {
      return ResponseHelper.notFound('Payment not found');
    }
  });

  router.post('/payments', (Request request) async {
    try {
      final body = await request.readAsString();
      final data = _parseFormData(body);
      
      // Validate input
      final validationErrors = ValidationService.instance.validatePayment(data);
      if (validationErrors.isNotEmpty) {
        return ResponseHelper.badRequest('Validation failed', errors: validationErrors);
      }
      
      // Sanitize input
      final sanitizedData = ValidationService.instance.sanitizeData(data);
      
      // Add created_at and updated_at timestamps
      sanitizedData['created_at'] = DateTime.now().toIso8601String();
      sanitizedData['updated_at'] = DateTime.now().toIso8601String();
      
      final payment = await ProductionSupabaseCrudService.instance.createPayment(sanitizedData);
      return ResponseHelper.created(payment);
    } catch (e) {
      return ResponseHelper.internalServerError(e.toString());
    }
  });

  router.put('/payments/<id>', (Request request, String id) async {
    try {
      final body = await request.readAsString();
      final data = _parseFormData(body);
      
      // Update timestamp
      data['updated_at'] = DateTime.now().toIso8601String();
      
      final sanitizedData = ValidationService.instance.sanitizeData(data);
      
      final payment = await ProductionSupabaseCrudService.instance.updatePayment(id, sanitizedData);
      return ResponseHelper.ok(payment);
    } catch (e) {
      return ResponseHelper.internalServerError(e.toString());
    }
  });

  router.delete('/payments/<id>', (Request request, String id) async {
    try {
      await ProductionSupabaseCrudService.instance.deletePayment(id);
      return ResponseHelper.ok({'message': 'Payment deleted successfully'});
    } catch (e) {
      return ResponseHelper.internalServerError(e.toString());
    }
  });

  // Tenant-specific data (requires authentication)
  router.get('/tenant/events', (Request request) async {
    try {
      final tenantId = getCurrentTenantId(request);
      if (tenantId == null) {
        return ResponseHelper.unauthorized('User not authenticated');
      }
      
      final events = await ProductionSupabaseCrudService.instance.getTenantEvents(tenantId);
      return ResponseHelper.ok(events);
    } catch (e) {
      return ResponseHelper.internalServerError(e.toString());
    }
  });

  router.get('/tenant/complaints', (Request request) async {
    try {
      final tenantId = getCurrentTenantId(request);
      if (tenantId == null) {
        return ResponseHelper.unauthorized('User not authenticated');
      }
      
      final complaints = await ProductionSupabaseCrudService.instance
          .getVisibleComplaintsForTenant(tenantId);
      return ResponseHelper.ok(complaints);
    } catch (e) {
      return ResponseHelper.internalServerError(e.toString());
    }
  });

  router.get('/tenant/payments', (Request request) async {
    try {
      final tenantId = getCurrentTenantId(request);
      if (tenantId == null) {
        return ResponseHelper.unauthorized('User not authenticated');
      }
      
      final payments = await ProductionSupabaseCrudService.instance
          .getTenantPaymentsWithLateFee(tenantId);
      return ResponseHelper.ok(payments);
    } catch (e) {
      return ResponseHelper.internalServerError(e.toString());
    }
  });

  // --- Cars (Admin) ---
  router.get('/admin/cars', (Request request) async {
    try {
      if (!isAdmin(request)) {
        return ResponseHelper.forbidden('Admin access required');
      }
      final cars = await ProductionSupabaseCrudService.instance.getCars();
      return ResponseHelper.ok(cars);
    } catch (e) {
      return ResponseHelper.internalServerError(e.toString());
    }
  });

  router.post('/admin/cars', (Request request) async {
    try {
      if (!isAdmin(request)) {
        return ResponseHelper.forbidden('Admin access required');
      }
      final body = await request.readAsString();
      final data = _parseJsonOrFormData(body);
      data['created_at'] = DateTime.now().toIso8601String();
      final created = await ProductionSupabaseCrudService.instance.createCar(data);
      return ResponseHelper.created(created);
    } catch (e) {
      return ResponseHelper.internalServerError(e.toString());
    }
  });

  router.delete('/admin/cars/<id>', (Request request, String id) async {
    try {
      if (!isAdmin(request)) {
        return ResponseHelper.forbidden('Admin access required');
      }
      await ProductionSupabaseCrudService.instance.deleteCar(id);
      return ResponseHelper.ok({'message': 'Car deleted successfully'});
    } catch (e) {
      return ResponseHelper.internalServerError(e.toString());
    }
  });

  // --- Staff (Admin) ---
  router.get('/admin/staff', (Request request) async {
    try {
      if (!isAdmin(request)) {
        return ResponseHelper.forbidden('Admin access required');
      }
      final staff = await ProductionSupabaseCrudService.instance.getStaff();
      return ResponseHelper.ok(staff);
    } catch (e) {
      return ResponseHelper.internalServerError(e.toString());
    }
  });

  router.post('/admin/staff', (Request request) async {
    try {
      if (!isAdmin(request)) {
        return ResponseHelper.forbidden('Admin access required');
      }
      final body = await request.readAsString();
      final data = _parseJsonOrFormData(body);
      data['created_at'] = DateTime.now().toIso8601String();
      final created = await ProductionSupabaseCrudService.instance.createStaff(data);
      return ResponseHelper.created(created);
    } catch (e) {
      return ResponseHelper.internalServerError(e.toString());
    }
  });

  router.patch('/admin/staff/<id>', (Request request, String id) async {
    try {
      if (!isAdmin(request)) {
        return ResponseHelper.forbidden('Admin access required');
      }
      final body = await request.readAsString();
      final data = _parseJsonOrFormData(body);
      data['updated_at'] = DateTime.now().toIso8601String();
      final updated =
          await ProductionSupabaseCrudService.instance.updateStaff(id, data);
      return ResponseHelper.ok(updated);
    } catch (e) {
      return ResponseHelper.internalServerError(e.toString());
    }
  });

  return router;
}

// Helper function to parse form data from request body
Map<String, dynamic> _parseFormData(String body) {
  final Map<String, dynamic> data = {};
  
  if (body.isEmpty) return data;
  
  // Parse form data (application/x-www-form-urlencoded)
  final pairs = body.split('&');
  for (final pair in pairs) {
    final keyValue = pair.split('=');
    if (keyValue.length == 2) {
      final key = Uri.decodeComponent(keyValue[0]);
      final value = Uri.decodeComponent(keyValue[1]);
      data[key] = value;
    }
  }
  
  return data;
}

Map<String, dynamic> _parseJsonOrFormData(String body) {
  final trimmed = body.trim();
  if (trimmed.isEmpty) return {};
  if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
    try {
      final decoded = jsonDecode(trimmed);
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (_) {}
  }
  return _parseFormData(body);
}
