import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackendConfig {
  static const String _kUseRealApi = 'use_real_api';
  static bool _useRealApi = false;

  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _useRealApi =
        prefs.getBool(_kUseRealApi) ??
        !bool.fromEnvironment('USE_MOCK_API', defaultValue: true);
  }

  static bool get isRealApi => _useRealApi;

  static Future<void> setUseRealApi(bool value) async {
    _useRealApi = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kUseRealApi, value);
  }

  static String get baseUrl {
    const override = String.fromEnvironment('BACKEND_BASE_URL');
    if (override.isNotEmpty) return override;

    final host = defaultTargetPlatform == TargetPlatform.android
        ? '10.0.2.2'
        : 'localhost';

    return 'http://$host:8081';
  }

  // Legacy support for other parts of the app
  static bool get useMockApi => !_useRealApi;

  static String get supabaseUrl => const String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://xglgbihqaiuuknbhlwaj.supabase.co',
  );

  static String get supabaseAnonKey => const String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhnbGdiaWhxYWl1dWtuYmhsd2FqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk4NTM3MTUsImV4cCI6MjA4NTQyOTcxNX0.8IlSMTIh-7Sfsfgd2a7vJ4JxsVWcTdWsN249WicMXbg',
  );
}
