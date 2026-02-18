import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../utils/response.dart';
import '../services/firebase_working_service.dart';
import '../services/supabase_service.dart';
import '../config/env.dart';

/// Health check routes
Router healthRoutes() {
  final router = Router();

  // Basic health check (enhanced for monitoring)
  router.get('/health', (Request req) {
    final now = DateTime.now();
    final uptime = now.difference(_startTime);
    return Response.ok(
      jsonEncode({
        'status': 'ok',
        'timestamp': now.toIso8601String(),
        'uptime': uptime.inSeconds,
        'uptimeHuman': _formatDuration(uptime),
        'server': 'OfficeHub Backend',
        'version': '1.0.0',
        'environment': Env.get('ENVIRONMENT', 'development'),
        'gitCommit': _gitCommitHash,
      }),
      headers: {'Content-Type': 'application/json'},
    );
  });

  // Legacy basic health (backward compatibility)
  router.get('/health/v1', (Request req) {
    return Response.ok(
      jsonEncode({
        'status': 'ok',
        'timestamp': DateTime.now().toIso8601String(),
        'server': 'OfficeHub Backend',
        'version': '1.0.0',
      }),
      headers: {'Content-Type': 'application/json'},
    );
  });

  // Detailed health check (can be extended with database checks)
  router.get('/health/detailed', (Request req) async {
    // Check Firebase service status
    String firebaseStatus = 'not_connected';
    try {
      final firebaseService = FirebaseWorkingService.instance;
      firebaseStatus = firebaseService.status;
    } catch (e) {
      firebaseStatus = 'error';
    }

    // Check Supabase service status
    String supabaseStatus = 'not_connected';
    try {
      final supabaseService = SupabaseService.instance;
      await supabaseService.ping();
      supabaseStatus = supabaseService.status;
    } catch (e) {
      supabaseStatus = 'error';
    }

    // Check database connectivity via Supabase PostgREST
    String databaseStatus = 'not_connected';
    try {
      final supabaseService = SupabaseService.instance;
      await supabaseService.pingDatabase();
      databaseStatus = supabaseService.dbStatus;
    } catch (e) {
      databaseStatus = 'error';
    }

    return ResponseHelper.ok({
      'status': 'ok',
      'timestamp': DateTime.now().toIso8601String(),
      'server': 'OfficeHub Backend',
      'version': '1.0.0',
      'services': {
        'database': databaseStatus,
        'firebase': firebaseStatus,
        'supabase': supabaseStatus,
      },
    });
  });

  return router;
}

// Private helpers
final DateTime _startTime = DateTime.now();

String _formatDuration(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  final seconds = duration.inSeconds.remainder(60);

  if (hours > 0) {
    return '${hours}h ${minutes}m ${seconds}s';
  } else if (minutes > 0) {
    return '${minutes}m ${seconds}s';
  } else {
    return '${seconds}s';
  }
}

String get _gitCommitHash {
  try {
    final result = Process.runSync('git', ['rev-parse', '--short', 'HEAD']);
    if (result.exitCode == 0) {
      return result.stdout.toString().trim();
    }
  } catch (e) {
    // Git not available or not a git repo
  }
  return 'unknown';
}
