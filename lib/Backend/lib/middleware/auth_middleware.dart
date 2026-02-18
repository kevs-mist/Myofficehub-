import 'package:shelf/shelf.dart';
import '../services/firebase_working_service.dart';
import '../services/supabase_crud_service_production.dart';
import '../utils/response.dart';

/// Authentication middleware for Firebase ID tokens
Middleware authMiddleware() {
  return (Handler innerHandler) {
    return (Request request) async {
      // Skip auth for health, auth, and supabase endpoints
      if (request.requestedUri.path.contains('/health') ||
          request.requestedUri.path.contains('/auth/') ||
          request.requestedUri.path.contains('/supabase/')) {
        return innerHandler(request);
      }

      // Extract Authorization header
      final authHeader = request.headers['authorization'];
      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return ResponseHelper.unauthorized(
            'Missing or invalid authorization header');
      }

      final idToken = authHeader.substring(7); // Remove 'Bearer ' prefix

      try {
        // Verify Firebase ID token using the working service
        final userRecord =
            await FirebaseWorkingService.instance.verifyIdToken(idToken);

        // AUTO-CREATE LOGIC: Resolve/create tenant row in Supabase on every valid request
        // This ensures the user exists in our database as soon as they authenticate with Firebase.
        final tenant = await ProductionSupabaseCrudService.instance
            .upsertTenantFromFirebase(
          firebaseUid: userRecord.uid,
          email: userRecord.email,
          displayName: userRecord.displayName,
        );

        final role = (tenant['role'] as String?) ?? _extractRole(userRecord);
        final tenantId = tenant['id'] as String?;

        // Add user info to request context
        final updatedRequest = request.change(
          context: {
            'user': userRecord,
            'uid': userRecord.uid,
            'email': userRecord.email,
            'role': role,
            'tenantId': tenantId,
          },
        );

        return innerHandler(updatedRequest);
      } catch (e) {
        return ResponseHelper.unauthorized('Invalid authentication token');
      }
    };
  };
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

/// Get current user from request context
UserRecord? getCurrentUser(Request request) {
  return request.context['user'] as UserRecord?;
}

/// Get current user ID from request context
String? getCurrentUserId(Request request) {
  return request.context['uid'] as String?;
}

/// Get current tenant UUID (Supabase) from request context
String? getCurrentTenantId(Request request) {
  return request.context['tenantId'] as String?;
}

/// Get current user role from request context
String? getCurrentUserRole(Request request) {
  return request.context['role'] as String?;
}

/// Check if current user is admin
bool isAdmin(Request request) {
  return getCurrentUserRole(request) == 'admin';
}

/// Check if current user is tenant
bool isTenant(Request request) {
  return getCurrentUserRole(request) == 'tenant';
}
