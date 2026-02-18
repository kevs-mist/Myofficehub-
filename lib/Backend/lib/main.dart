import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import 'config/env.dart';
import 'config/cors.dart';
import 'routes/health.dart';
import 'routes/auth.dart';
import 'routes/supabase.dart';
import 'routes/crud.dart';
import 'routes/realtime_simple.dart';
import 'middleware/auth_middleware.dart';
import 'services/firebase_working_service.dart';
import 'services/supabase_service.dart';
import 'services/supabase_crud_service_production.dart';
import 'services/realtime_service_production.dart';
import 'middleware/rate_limiter.dart';
import 'utils/response.dart';

void main() async {
  // Load environment variables
  await Env.load();

  // Initialize Firebase
  try {
    await FirebaseWorkingService.instance.initialize();
  } catch (e) {
    print('⚠️  Firebase initialization failed: $e');
    print('🔥 Server will continue with limited authentication');
  }

  // Initialize Supabase
  try {
    await SupabaseService.instance.initialize();
    await ProductionSupabaseCrudService.instance.initialize();
    await ProductionRealtimeService.instance.initialize();
  } catch (e) {
    print('⚠️  Supabase initialization failed: $e');
    print('🗄️  Server will continue with limited database functionality');
  }

  // Create router
  final router = Router();

  // Add health routes (no auth required)
  router.mount('/api/v1', healthRoutes().call);

  // Add auth routes (no auth required for login)
  router.mount('/api/v1', authRoutes().call);

  // Add Supabase routes (no auth required)
  router.mount('/api/v1', supabaseRoutes().call);

  // Add CRUD routes (requires authentication)
  router.mount('/api/v1', crudRoutes().call);

  // Add Realtime routes (requires authentication)
  router.mount('/api/v1', realtimeRoutes().call);

  // Add 404 handler
  router.all('/<ignored|.*>', (Request request) {
    return ResponseHelper.notFound('Endpoint not found');
  });

  // Create handler with CORS, rate limiting, and auth middleware
  final handler = const Pipeline()
      .addMiddleware(logRequests()) // Standard structured logging
      .addMiddleware(cors())
      .addMiddleware(rateLimiter(maxRequests: 200)) // Phase 8: Security
      .addMiddleware(authMiddleware())
      .addHandler(router.call);

  // Start server
  final host = Env.host;
  final port = Env.port;

  final server = await HttpServer.bind(host, port);

  print('🚀 OfficeHub Backend Server');
  print('📍 Server running on http://$host:$port');
  print('🏥 Health check: http://$host:$port/api/v1/health');
  print('🔍 Detailed health: http://$host:$port/api/v1/health/detailed');
  print('');
  print('Press Ctrl+C to stop the server');

  // Start serving requests
  await serveRequests(handler, server);
}

Future<void> serveRequests(Handler handler, HttpServer server) async {
  await for (final HttpRequest request in server) {
    try {
      // Convert HttpRequest to Shelf Request
      final headers = <String, String>{};
      request.headers.forEach((name, values) {
        headers[name] = values.join(', ');
      });

      final shelfRequest = Request(
        request.method,
        request.requestedUri,
        protocolVersion: request.protocolVersion,
        headers: headers,
        body: request,
      );

      final response = await handler(shelfRequest);

      // Set response headers and status code
      request.response.statusCode = response.statusCode;
      response.headers.forEach((name, value) {
        request.response.headers.set(name, value);
      });

      // Write response body
      final body = await response.read().toList();
      if (body.isNotEmpty) {
        for (final chunk in body) {
          request.response.add(chunk);
        }
      }

      await request.response.close();
    } catch (e, stackTrace) {
      print('❌ Error handling request: $e');
      print('Stack trace: $stackTrace');

      request.response.statusCode = 500;
      request.response.headers.set('content-type', 'application/json');
      request.response
          .write('{"success": false, "message": "Internal server error"}');
      await request.response.close();
    }
  }
}
