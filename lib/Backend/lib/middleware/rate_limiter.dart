import 'package:shelf/shelf.dart';

/// Simple IP-based rate limiter middleware
Middleware rateLimiter({
  int maxRequests = 100,
  Duration window = const Duration(minutes: 1),
}) {
  final Map<String, List<DateTime>> requestHistory = {};

  return (Handler innerHandler) {
    return (Request request) async {
      final ip = request.context['shelf.io.connection_info'] != null
          ? (request.context['shelf.io.connection_info'] as dynamic)
              .remoteAddress
              .address
          : 'unknown';

      final now = DateTime.now();
      final history = requestHistory[ip] ?? [];

      // Clean old requests
      history.removeWhere((time) => now.difference(time) > window);

      if (history.length >= maxRequests) {
        return Response(429,
            body: 'Too Many Requests. Please try again later.');
      }

      history.add(now);
      requestHistory[ip] = history;

      return await innerHandler(request);
    };
  };
}
