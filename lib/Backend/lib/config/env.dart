import 'package:dotenv/dotenv.dart';

class Env {
  static late DotEnv _env;

  static Future<void> load() async {
    _env = DotEnv(includePlatformEnvironment: true)..load();
  }

  static String get(String key, [String? defaultValue]) {
    return _env[key] ?? defaultValue ?? '';
  }

  static int getInt(String key, [int defaultValue = 0]) {
    final value = _env[key];
    if (value == null) return defaultValue;
    return int.tryParse(value) ?? defaultValue;
  }

  static bool getBool(String key, [bool defaultValue = false]) {
    final value = _env[key];
    if (value == null) return defaultValue;
    return value.toLowerCase() == 'true';
  }

  // Server Configuration
  static String get host => get('HOST', 'localhost');
  static int get port => getInt('PORT', 8081);

  // Firebase Configuration
  static String get firebaseProjectId => get('FIREBASE_PROJECT_ID');
  static String get firebaseServiceAccountKeyPath => get('FIREBASE_SERVICE_ACCOUNT_KEY_PATH');

  // Supabase Configuration
  static String get supabaseUrl => get('SUPABASE_URL');
  static String get supabaseAnonKey => get('SUPABASE_ANON_KEY');
  static String get supabaseServiceKey => get('SUPABASE_SERVICE_KEY');

  // Razorpay Configuration
  static String get razorpayKeyId => get('RAZORPAY_KEY_ID');
  static String get razorpayKeySecret => get('RAZORPAY_KEY_SECRET');
}
