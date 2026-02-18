import 'dart:convert';
import 'package:shelf/shelf.dart';

/// Standardized response helper
class ResponseHelper {
  static Response ok(dynamic data, {String message = 'Success'}) {
    return Response.ok(
      jsonEncode({
        'success': true,
        'message': message,
        'data': data,
      }),
      headers: {'Content-Type': 'application/json'},
    );
  }

  static Response created(dynamic data, {String message = 'Created successfully'}) {
    return Response(
      201,
      body: jsonEncode({
        'success': true,
        'message': message,
        'data': data,
      }),
      headers: {'Content-Type': 'application/json'},
    );
  }

  static Response badRequest(String message, {dynamic errors}) {
    return Response(
      400,
      body: jsonEncode({
        'success': false,
        'message': message,
        'errors': errors,
      }),
      headers: {'Content-Type': 'application/json'},
    );
  }

  static Response unauthorized(String message) {
    return Response(
      401,
      body: jsonEncode({
        'success': false,
        'message': message,
      }),
      headers: {'Content-Type': 'application/json'},
    );
  }

  static Response forbidden(String message) {
    return Response(
      403,
      body: jsonEncode({
        'success': false,
        'message': message,
      }),
      headers: {'Content-Type': 'application/json'},
    );
  }

  static Response notFound(String message) {
    return Response(
      404,
      body: jsonEncode({
        'success': false,
        'message': message,
      }),
      headers: {'Content-Type': 'application/json'},
    );
  }

  static Response internalServerError(String message) {
    return Response(
      500,
      body: jsonEncode({
        'success': false,
        'message': message,
      }),
      headers: {'Content-Type': 'application/json'},
    );
  }
}
