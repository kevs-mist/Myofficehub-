import 'package:shelf/shelf.dart';
import '../utils/response.dart';
import 'auth_middleware.dart';

/// Role-based access control middleware
Middleware rbacMiddleware({
  required List<String> allowedRoles,
  String? customErrorMessage,
}) {
  return (Handler innerHandler) {
    return (Request request) async {
      final userRole = getCurrentUserRole(request);
      
      if (userRole == null) {
        return ResponseHelper.unauthorized('User role not found');
      }

      if (!allowedRoles.contains(userRole)) {
        return ResponseHelper.forbidden(
          customErrorMessage ?? 
          'Access denied. Required roles: ${allowedRoles.join(', ')}'
        );
      }

      return innerHandler(request);
    };
  };
}

/// Admin-only middleware
Middleware adminOnly() {
  return rbacMiddleware(allowedRoles: ['admin']);
}

/// Tenant-only middleware
Middleware tenantOnly() {
  return rbacMiddleware(allowedRoles: ['tenant']);
}

/// Admin or tenant middleware
Middleware adminOrTenant() {
  return rbacMiddleware(allowedRoles: ['admin', 'tenant']);
}
