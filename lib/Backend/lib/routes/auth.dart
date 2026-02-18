import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/firebase_working_service.dart';
import '../services/supabase_crud_service_production.dart';
import '../utils/response.dart';
import '../middleware/auth_middleware.dart';

/// Authentication routes
Router authRoutes() {
  final router = Router();

  // Verify Firebase token and return user info
  router.post('/auth/verify', (Request request) async {
    try {
      final body = await request.readAsString();
      Map<String, dynamic> data = {};

      if (body.isNotEmpty) {
        // Parse JSON body if present
        try {
          data = Map<String, dynamic>.from(
              // Simple JSON parsing for token
              body.split('&').fold(<String, String>{}, (map, pair) {
            final keyValue = pair.split('=');
            if (keyValue.length == 2) {
              map[keyValue[0]] = Uri.decodeComponent(keyValue[1]);
            }
            return map;
          }));
        } catch (e) {
          // If parsing fails, try as JSON
          data = {};
        }
      }

      final idToken = data['idToken'] as String?;
      if (idToken == null || idToken.isEmpty) {
        return ResponseHelper.badRequest('idToken is required');
      }

      // Verify the token
      final userRecord =
          await FirebaseWorkingService.instance.verifyIdToken(idToken);

      return ResponseHelper.ok({
        'uid': userRecord.uid,
        'email': userRecord.email,
        'displayName': userRecord.displayName,
        'role': _extractRole(userRecord),
        'emailVerified': userRecord.emailVerified,
        'photoUrl': userRecord.photoUrl,
      }, message: 'Token verified successfully');
    } catch (e) {
      return ResponseHelper.unauthorized('Invalid authentication token');
    }
  });

  // Get current user info (requires authentication)
  router.get('/auth/me', (Request request) async {
    final user = getCurrentUser(request);
    if (user == null) {
      return ResponseHelper.unauthorized('User not authenticated');
    }

    final tenantId = getCurrentTenantId(request);
    final role = getCurrentUserRole(request);
    if (tenantId == null || role == null) {
      return ResponseHelper.unauthorized('Tenant mapping not found');
    }

    // Enrich with tenant profile if available
    Map<String, dynamic>? tenantProfile;
    try {
      tenantProfile = await ProductionSupabaseCrudService.instance
          .getTenantProfile(tenantId);
    } catch (_) {}

    // Enrich with admin settings if role=admin
    Map<String, dynamic>? adminSettings;
    if (role == 'admin') {
      try {
        adminSettings = await ProductionSupabaseCrudService.instance
            .getAdminSettings(tenantId);
      } catch (_) {}
    }

    return ResponseHelper.ok({
      'uid': user.uid,
      'email': user.email,
      'displayName': user.displayName,
      'role': role,
      'tenantId': tenantId,
      'tenantProfile': tenantProfile,
      'adminSettings': adminSettings,
      'emailVerified': user.emailVerified,
      'photoUrl': user.photoUrl,
      'customClaims': user.customClaims,
    });
  });

  // Refresh token endpoint (placeholder)
  router.post('/auth/refresh', (Request request) async {
    // In a real implementation, you might handle token refresh here
    // For now, Firebase ID tokens are self-contained and don't need refresh
    return ResponseHelper.ok({
      'message': 'Firebase ID tokens are self-contained. Use verify endpoint.',
    });
  });

  return router;
}

/// Extract role from Firebase user custom claims or email
String _extractRole(UserRecord user) {
  // Check custom claims first
  final customClaims = user.customClaims;
  if (customClaims != null && customClaims['role'] != null) {
    return customClaims['role'] as String;
  }

  // Fallback: determine role from email pattern (development only)
  final email = user.email;
  if (email != null) {
    if (email.contains('admin@') || email.endsWith('@skyline.com')) {
      return 'admin';
    } else {
      return 'tenant';
    }
  }

  // Default to tenant
  return 'tenant';
}
