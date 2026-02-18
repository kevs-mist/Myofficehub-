import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../services/supabase_service.dart';
import '../utils/response.dart';

Router supabaseRoutes() {
  final router = Router();

  router.get('/supabase/ping', (Request req) async {
    try {
      final ok = await SupabaseService.instance.ping();
      if (!ok) {
        return ResponseHelper.internalServerError(
          SupabaseService.instance.lastError ?? 'Supabase ping failed',
        );
      }

      return ResponseHelper.ok({
        'status': 'connected',
      });
    } catch (e) {
      return ResponseHelper.internalServerError(e.toString());
    }
  });

  router.get('/supabase/db/ping', (Request req) async {
    try {
      final ok = await SupabaseService.instance.pingDatabase();
      if (!ok) {
        return ResponseHelper.internalServerError(
          SupabaseService.instance.lastDbError ?? 'Supabase database ping failed',
        );
      }

      return ResponseHelper.ok({
        'status': 'connected',
      });
    } catch (e) {
      return ResponseHelper.internalServerError(e.toString());
    }
  });

  return router;
}
