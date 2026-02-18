import 'package:http/http.dart' as http;
import 'package:supabase/supabase.dart';

import '../config/env.dart';

class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance => _instance ??= SupabaseService._();

  SupabaseService._();

  bool _initialized = false;
  bool _connected = false;
  bool _dbConnected = false;
  String? _lastError;
  String? _lastDbError;

  late SupabaseClient _client;

  Future<void> initialize() async {
    if (_initialized) return;

    final url = Env.supabaseUrl.trim();
    final key = _apiKey;

    if (url.isEmpty) {
      throw Exception('SUPABASE_URL not set in environment');
    }
    final parsed = Uri.tryParse(url);
    if (parsed == null || !parsed.hasScheme || parsed.host.isEmpty) {
      throw Exception('SUPABASE_URL is invalid: $url');
    }
    if (key.isEmpty) {
      throw Exception('SUPABASE_SERVICE_KEY (preferred) or SUPABASE_ANON_KEY not set');
    }

    _client = SupabaseClient(url, key);

    try {
      await ping();
      _initialized = true;
    } catch (e) {
      _initialized = true;
      rethrow;
    }
  }

  String get _apiKey {
    final serviceKey = Env.supabaseServiceKey.trim();
    if (serviceKey.isNotEmpty) return serviceKey;
    return Env.supabaseAnonKey.trim();
  }

  SupabaseClient get client {
    if (!_initialized) {
      throw Exception('Supabase not initialized. Call initialize() first.');
    }
    return _client;
  }

  Future<bool> ping() async {
    final url = Env.supabaseUrl.trim();
    final key = _apiKey;

    final base = Uri.tryParse(url);
    if (base == null || !base.hasScheme || base.host.isEmpty) {
      _connected = false;
      _lastError = 'SUPABASE_URL is invalid: $url';
      return false;
    }

    final uri = base.replace(path: '/auth/v1/health');
    try {
      final res = await http.get(
        uri,
        headers: {
          'apikey': key,
          'authorization': 'Bearer $key',
        },
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
        _connected = true;
        _lastError = null;
        return true;
      }

      _connected = false;
      _lastError = 'Supabase health returned ${res.statusCode}: ${res.body}';
      return false;
    } catch (e) {
      _connected = false;
      _lastError = e.toString();
      return false;
    }
  }

  Future<bool> pingDatabase() async {
    final url = Env.supabaseUrl.trim();
    final key = _apiKey;

    final base = Uri.tryParse(url);
    if (base == null || !base.hasScheme || base.host.isEmpty) {
      _dbConnected = false;
      _lastDbError = 'SUPABASE_URL is invalid: $url';
      return false;
    }

    final uri = base.replace(path: '/rest/v1/');
    try {
      final res = await http.get(
        uri,
        headers: {
          'apikey': key,
          'authorization': 'Bearer $key',
          'accept': 'application/openapi+json',
        },
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
        _dbConnected = true;
        _lastDbError = null;
        return true;
      }

      _dbConnected = false;
      _lastDbError = 'PostgREST returned ${res.statusCode}: ${res.body}';
      return false;
    } catch (e) {
      _dbConnected = false;
      _lastDbError = e.toString();
      return false;
    }
  }

  bool get isInitialized => _initialized;
  bool get isConnected => _connected;
  bool get isDbConnected => _dbConnected;
  String? get lastError => _lastError;
  String? get lastDbError => _lastDbError;

  String get status {
    if (!_initialized) return 'not_initialized';
    return _connected ? 'connected' : 'error';
  }

  String get dbStatus {
    if (!_initialized) return 'not_initialized';
    return _dbConnected ? 'connected' : 'error';
  }
}
