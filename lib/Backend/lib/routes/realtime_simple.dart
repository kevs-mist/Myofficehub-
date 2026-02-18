import 'dart:async';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/realtime_service_production.dart';
import '../utils/response.dart';
import '../middleware/auth_middleware.dart';

/// Simple Real-time routes (REST-based polling for now)
Router realtimeRoutes() {
  final router = Router();

  // REST endpoint to get real-time status
  router.get('/realtime/status', (Request request) async {
    try {
      final tenantId = getCurrentUserId(request);
      final userRole = getCurrentUserRole(request);
      
      if (tenantId == null) {
        return ResponseHelper.unauthorized('User not authenticated');
      }

      return ResponseHelper.ok({
        'connected': true,
        'activeSubscriptions': ProductionRealtimeService.instance.getActiveSubscriptions(),
        'userRole': userRole,
        'tenantId': tenantId,
        'message': 'Real-time service is running (WebSocket coming soon)',
      });
    } catch (e) {
      return ResponseHelper.internalServerError(e.toString());
    }
  });

  // Admin endpoint to broadcast notifications
  router.post('/realtime/broadcast', (Request request) async {
    try {
      final userRole = getCurrentUserRole(request);
      if (userRole != 'admin') {
        return ResponseHelper.forbidden('Admin access required');
      }

      final body = await request.readAsString();
      final data = _parseFormData(body);
      
      final message = data['message'] as String?;
      final type = data['type'] as String?;
      
      if (message == null || message.isEmpty) {
        return ResponseHelper.badRequest('Message is required');
      }

      // Broadcast to all connected clients
      ProductionRealtimeService.instance.broadcastNotification(message, type: type);

      return ResponseHelper.ok({
        'message': 'Notification broadcasted successfully',
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      return ResponseHelper.internalServerError(e.toString());
    }
  });

  // Admin endpoint to send notification to specific tenant
  router.post('/realtime/notify/<tenantId>', (Request request, String tenantId) async {
    try {
      final userRole = getCurrentUserRole(request);
      if (userRole != 'admin') {
        return ResponseHelper.forbidden('Admin access required');
      }

      final body = await request.readAsString();
      final data = _parseFormData(body);
      
      final message = data['message'] as String?;
      final type = data['type'] as String?;
      
      if (message == null || message.isEmpty) {
        return ResponseHelper.badRequest('Message is required');
      }

      // Send notification to specific tenant
      ProductionRealtimeService.instance.sendNotificationToTenant(tenantId, message, type: type);

      return ResponseHelper.ok({
        'message': 'Notification sent successfully',
        'tenantId': tenantId,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      return ResponseHelper.internalServerError(e.toString());
    }
  });

  // Test endpoint for real-time subscriptions
  router.get('/realtime/test/<table>', (Request request, String table) async {
    try {
      final tenantId = getCurrentUserId(request);
      final userRole = getCurrentUserRole(request);
      
      if (tenantId == null) {
        return ResponseHelper.unauthorized('User not authenticated');
      }

      // Test subscription to table
      Stream<Map<String, dynamic>> stream;
      
      switch (table) {
        case 'events':
          stream = userRole == 'admin' 
              ? ProductionRealtimeService.instance.subscribeToEvents()
              : ProductionRealtimeService.instance.subscribeToEvents(tenantId: tenantId);
          break;
        case 'complaints':
          stream = userRole == 'admin' 
              ? ProductionRealtimeService.instance.subscribeToComplaints()
              : ProductionRealtimeService.instance.subscribeToComplaints(tenantId: tenantId);
          break;
        case 'payments':
          stream = userRole == 'admin' 
              ? ProductionRealtimeService.instance.subscribeToPayments()
              : ProductionRealtimeService.instance.subscribeToPayments(tenantId: tenantId);
          break;
        case 'tenants':
          if (userRole != 'admin') {
            return ResponseHelper.forbidden('Admin access required');
          }
          stream = ProductionRealtimeService.instance.subscribeToTenants();
          break;
        default:
          return ResponseHelper.badRequest('Invalid table name');
      }

      // Listen for a few events and return them
      final events = <Map<String, dynamic>>[];
      late StreamSubscription subscription;
      
      subscription = stream.listen((event) {
        events.add(event);
        if (events.length >= 3) {
          subscription.cancel();
        }
      });

      // Wait a bit for events
      await Future.delayed(Duration(seconds: 2));
      subscription.cancel();

      return ResponseHelper.ok({
        'table': table,
        'events': events,
        'subscriptionStatus': ProductionRealtimeService.instance.isSubscribed(table, tenantId: userRole == 'tenant' ? tenantId : null),
        'timestamp': DateTime.now().toIso8601String(),
      });
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
