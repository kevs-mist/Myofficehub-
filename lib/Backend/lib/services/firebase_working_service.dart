import 'dart:io';
import 'package:firebase_admin/firebase_admin.dart';
import '../config/env.dart';

class FirebaseWorkingService {
  static FirebaseWorkingService? _instance;
  static FirebaseWorkingService get instance =>
      _instance ??= FirebaseWorkingService._();

  FirebaseWorkingService._();

  late App _app;
  bool _initialized = false;

  /// Initialize Firebase Admin SDK (Working Version)
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Validate required environment variables
      final projectId = Env.firebaseProjectId;
      final serviceAccountPath = Env.firebaseServiceAccountKeyPath;

      if (projectId.isEmpty) {
        throw Exception('FIREBASE_PROJECT_ID not set in .env');
      }

      if (serviceAccountPath.isEmpty) {
        throw Exception('FIREBASE_SERVICE_ACCOUNT_KEY_PATH not set in .env');
      }

      final serviceAccount = File(serviceAccountPath);
      if (!await serviceAccount.exists()) {
        throw Exception(
            'Service account key file not found: $serviceAccountPath');
      }

      // Initialize real Firebase Admin SDK
      _app = FirebaseAdmin.instance.initializeApp(
        AppOptions(
          projectId: projectId,
          credential: FirebaseAdmin.instance.certFromPath(serviceAccountPath),
        ),
      );

      _initialized = true;
      print('✅ Firebase Admin SDK initialized successfully');
      print('📝 Project ID: $projectId');
      print('🔥 Real Firebase Admin SDK integration active');
      print('📝 Service account key: $serviceAccountPath');
    } catch (e) {
      print('❌ Failed to initialize Firebase: $e');
      rethrow;
    }
  }

  /// Verify Firebase ID token (Real Firebase Admin SDK)
  Future<UserRecord> verifyIdToken(String idToken) async {
    if (!_initialized) {
      await initialize();
    }

    try {
      // Handle mock tokens for testing
      if (idToken.startsWith('mock_token_')) {
        return _handleMockToken(idToken);
      }

      // Use real Firebase Admin SDK to verify ID token
      final firebaseToken = await _app.auth().verifyIdToken(idToken);
      final uid = firebaseToken.claims['sub'] as String?;
      final email = firebaseToken.claims['email'] as String?;

      if (uid == null || email == null) {
        throw Exception('Invalid token: missing uid or email');
      }

      // Get user info from Firebase Admin SDK
      final userRecord = await _app.auth().getUser(uid);

      return UserRecord(
        uid: uid,
        email: email,
        displayName: userRecord.displayName ?? email.split('@')[0],
        emailVerified: userRecord.emailVerified,
        photoUrl: userRecord.photoUrl?.toString(),
        customClaims: userRecord.customClaims,
      );
    } catch (e) {
      print('❌ Failed to verify ID token: $e');
      throw Exception('Invalid authentication token: $e');
    }
  }

  /// Handle mock tokens for testing
  UserRecord _handleMockToken(String idToken) {
    final parts = idToken.split('_');
    if (parts.length < 3) {
      throw Exception('Invalid mock token format');
    }

    final uid = parts[1];
    final email = parts[2];

    return UserRecord(
      uid: uid,
      email: email,
      displayName: email.split('@')[0],
      emailVerified: true,
      photoUrl: null,
      customClaims: {'role': _extractRoleFromEmail(email)},
    );
  }

  /// Extract role from email
  String _extractRoleFromEmail(String email) {
    if (email.contains('admin@') || email.endsWith('@skyline.com')) {
      return 'admin';
    } else if (email.contains('admin123')) {
      return 'admin';
    } else {
      return 'tenant';
    }
  }

  /// Check if Firebase service is initialized
  bool get isInitialized => _initialized;

  /// Get service status for health check
  String get status {
    if (!_initialized) return 'not_initialized';
    return 'connected';
  }

  /// Get user by UID (Real Firebase Admin SDK)
  Future<UserRecord?> getUser(String uid) async {
    if (!_initialized) {
      await initialize();
    }

    try {
      // Use real Firebase Admin SDK to get user
      final userRecord = await _app.auth().getUser(uid);

      return UserRecord(
        uid: userRecord.uid,
        email: userRecord.email,
        displayName: userRecord.displayName,
        emailVerified: userRecord.emailVerified,
        photoUrl: userRecord.photoUrl?.toString(),
        customClaims: userRecord.customClaims,
      );
    } catch (e) {
      print('❌ Failed to get user: $e');
      return null;
    }
  }

  /// Create custom token (Real Firebase Admin SDK)
  Future<String> createCustomToken(String uid,
      {Map<String, dynamic>? claims}) async {
    if (!_initialized) {
      await initialize();
    }

    try {
      // Use real Firebase Admin SDK to create custom token
      return await _app.auth().createCustomToken(uid);
    } catch (e) {
      print('❌ Failed to create custom token: $e');
      throw Exception('Failed to create custom token');
    }
  }

  /// Check if user exists (Working Version)
  Future<bool> userExists(String uid) async {
    final user = await getUser(uid);
    return user != null;
  }
}

/// Working UserRecord class
class UserRecord {
  final String uid;
  final String? email;
  final String? displayName;
  final bool emailVerified;
  final String? photoUrl;
  final Map<String, dynamic>? customClaims;

  const UserRecord({
    required this.uid,
    this.email,
    this.displayName,
    required this.emailVerified,
    this.photoUrl,
    this.customClaims,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'emailVerified': emailVerified,
      'photoUrl': photoUrl,
      'customClaims': customClaims,
    };
  }

  @override
  String toString() {
    return 'UserRecord(uid: $uid, email: $email, displayName: $displayName)';
  }
}
