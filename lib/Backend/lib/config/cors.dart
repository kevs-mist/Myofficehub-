import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:shelf/shelf.dart';
import 'env.dart';

/// CORS configuration for Flutter frontend
Middleware cors() {
  final allowedOrigin = Env.get('ALLOWED_ORIGIN', '*');

  return corsHeaders(
    headers: {
      'Access-Control-Allow-Origin': allowedOrigin,
      'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, PATCH, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, Authorization',
      'Access-Control-Max-Age': '86400', // 24 hours
    },
  );
}
