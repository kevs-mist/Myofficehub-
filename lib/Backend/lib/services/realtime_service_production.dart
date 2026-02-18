import 'dart:async';
import 'package:supabase/supabase.dart';
import '../config/env.dart';

class ProductionRealtimeService {
  static ProductionRealtimeService? _instance;
  static ProductionRealtimeService get instance => _instance ??= ProductionRealtimeService._();
  
  ProductionRealtimeService._();
  
  late SupabaseClient _client;
  bool _initialized = false;
  
  // Stream controllers for different tables
  final Map<String, StreamController<Map<String, dynamic>>> _controllers = {};
  final Map<String, RealtimeChannel> _subscriptions = {};

  Future<void> initialize() async {
    if (_initialized) return;

    final url = Env.supabaseUrl.trim();
    final key = _apiKey;

    if (url.isEmpty) {
      throw Exception('SUPABASE_URL not set in environment');
    }
    if (key.isEmpty) {
      throw Exception('SUPABASE_SERVICE_KEY (preferred) or SUPABASE_ANON_KEY not set');
    }

    _client = SupabaseClient(url, key);
    _initialized = true;
    print('✅ Production Realtime service initialized');
  }

  String get _apiKey {
    final serviceKey = Env.supabaseServiceKey.trim();
    if (serviceKey.isNotEmpty) return serviceKey;
    return Env.supabaseAnonKey.trim();
  }

  SupabaseClient get client {
    if (!_initialized) {
      throw Exception('Realtime service not initialized. Call initialize() first.');
    }
    return _client;
  }

  // Subscribe to table changes with proper error handling
  Stream<Map<String, dynamic>> subscribeToTable(String tableName, {String? tenantId}) {
    final key = tenantId != null ? '${tableName}_$tenantId' : tableName;
    
    if (_controllers.containsKey(key)) {
      return _controllers[key]!.stream;
    }

    final controller = StreamController<Map<String, dynamic>>.broadcast();
    _controllers[key] = controller;

    try {
      // Create real-time subscription
      RealtimeChannel channel;
      
      if (tenantId != null) {
        // Tenant-specific subscription
        channel = _client
            .channel('public:$tableName')
            .onPostgresChanges(
              event: PostgresChangeEvent.all,
              schema: 'public',
              table: tableName,
              filter: PostgresChangeFilter(
                type: PostgresChangeFilterType.eq,
                column: 'tenant_id',
                value: tenantId,
              ),
              callback: (payload, [ref]) {
                _handleRealtimeEvent(controller, payload);
              },
            )
            .subscribe();
      } else {
        // Admin subscription (all records)
        channel = _client
            .channel('public:$tableName')
            .onPostgresChanges(
              event: PostgresChangeEvent.all,
              schema: 'public',
              table: tableName,
              callback: (payload, [ref]) {
                _handleRealtimeEvent(controller, payload);
              },
            )
            .subscribe();
      }

      _subscriptions[key] = channel;
      print('✅ Subscribed to $tableName${tenantId != null ? ' for tenant $tenantId' : ''}');
      
    } catch (e) {
      print('❌ Failed to subscribe to $tableName: $e');
      // Add error event to stream
      controller.add({
        'error': true,
        'message': 'Failed to subscribe to $tableName',
        'details': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      });
    }

    return controller.stream;
  }

  void _handleRealtimeEvent(StreamController<Map<String, dynamic>> controller, PostgresChangePayload payload) {
    try {
      final event = {
        'eventType': payload.eventType,
        'table': payload.table,
        'schema': payload.schema,
        'commit_timestamp': payload.commitTimestamp,
        'old_record': payload.oldRecord,
        'new_record': payload.newRecord,
        'timestamp': DateTime.now().toIso8601String(),
      };

      controller.add(event);
      print('📡 Real-time event: ${payload.eventType} on ${payload.table}');
    } catch (e) {
      print('❌ Error handling real-time event: $e');
      controller.add({
        'error': true,
        'message': 'Error processing real-time event',
        'details': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
  }

  // Subscribe to events
  Stream<Map<String, dynamic>> subscribeToEvents({String? tenantId}) {
    return subscribeToTable('events', tenantId: tenantId);
  }

  // Subscribe to complaints
  Stream<Map<String, dynamic>> subscribeToComplaints({String? tenantId}) {
    return subscribeToTable('complaints', tenantId: tenantId);
  }

  // Subscribe to payments
  Stream<Map<String, dynamic>> subscribeToPayments({String? tenantId}) {
    return subscribeToTable('payments', tenantId: tenantId);
  }

  // Subscribe to tenants (admin only)
  Stream<Map<String, dynamic>> subscribeToTenants() {
    return subscribeToTable('tenants');
  }

  // Unsubscribe from a specific table
  Future<void> unsubscribe(String tableName, {String? tenantId}) async {
    final key = tenantId != null ? '${tableName}_$tenantId' : tableName;
    
    final channel = _subscriptions[key];
    if (channel != null) {
      try {
        await _client.removeChannel(channel);
        _subscriptions.remove(key);
        print('✅ Unsubscribed from $tableName${tenantId != null ? ' for tenant $tenantId' : ''}');
      } catch (e) {
        print('❌ Failed to unsubscribe from $tableName: $e');
      }
    }

    final controller = _controllers[key];
    if (controller != null) {
      await controller.close();
      _controllers.remove(key);
    }
  }

  // Unsubscribe from all subscriptions
  Future<void> unsubscribeAll() async {
    for (final entry in _subscriptions.entries) {
      try {
        await _client.removeChannel(entry.value);
      } catch (e) {
        print('❌ Failed to remove channel ${entry.key}: $e');
      }
    }
    _subscriptions.clear();

    for (final controller in _controllers.values) {
      await controller.close();
    }
    _controllers.clear();
    
    print('✅ Unsubscribed from all real-time subscriptions');
  }

  // Get subscription status
  bool isSubscribed(String tableName, {String? tenantId}) {
    final key = tenantId != null ? '${tableName}_$tenantId' : tableName;
    return _subscriptions.containsKey(key);
  }

  // Get all active subscriptions
  List<String> getActiveSubscriptions() {
    return _subscriptions.keys.toList();
  }

  // Broadcast message to all connected clients (for admin notifications)
  void broadcastNotification(String message, {String? type = 'info'}) {
    final notification = {
      'type': type ?? 'info',
      'message': message,
      'timestamp': DateTime.now().toIso8601String(),
      'broadcast': true,
    };

    // Send to all active controllers
    for (final controller in _controllers.values) {
      if (!controller.isClosed) {
        controller.add(notification);
      }
    }
    
    print('📢 Broadcast notification: $message');
  }

  // Send notification to specific tenant
  void sendNotificationToTenant(String tenantId, String message, {String? type = 'info'}) {
    final notification = {
      'type': type ?? 'info',
      'message': message,
      'tenantId': tenantId,
      'timestamp': DateTime.now().toIso8601String(),
      'broadcast': false,
    };

    // Send to tenant-specific controllers
    for (final entry in _controllers.entries) {
      if (entry.key.contains('_$tenantId') && !entry.value.isClosed) {
        entry.value.add(notification);
      }
    }
    
    print('📨 Sent notification to tenant $tenantId: $message');
  }

  // Health check for real-time service
  Map<String, dynamic> getHealthStatus() {
    return {
      'initialized': _initialized,
      'activeSubscriptions': _subscriptions.length,
      'activeControllers': _controllers.length,
      'subscriptionKeys': _subscriptions.keys.toList(),
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  // Dispose service
  Future<void> dispose() async {
    await unsubscribeAll();
    print('✅ Production Realtime service disposed');
  }
}
