import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/app_state_provider.dart';

final notificationServiceProvider = Provider((ref) => NotificationService(ref));

class NotificationService {
  final Ref _ref;

  NotificationService(this._ref);

  bool get _isFirebaseInitialized => Firebase.apps.isNotEmpty;

  FirebaseMessaging get _fcm => FirebaseMessaging.instance;

  Future<void> initialize() async {
    if (!_isFirebaseInitialized) {
      if (kDebugMode) {
        print('Skipping notification initialization: Firebase not initialized.');
      }
      return;
    }

    // Listen for incoming messages when app is in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('Handling a foreground message: ${message.messageId}');
        print('Message data: ${message.data}');
        print('Message notification: ${message.notification?.title}');
      }
      // You could show a local notification here if desired
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('Message clicked!');
      }
      // Handle navigation if needed
    });
  }

  Future<bool> requestPermissions() async {
    if (!_isFirebaseInitialized) {
      if (kDebugMode) {
        print('Cannot request notification permissions: Firebase not initialized.');
      }
      return false;
    }

    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) print('User granted permission');
      await _updateToken();
      return true;
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      if (kDebugMode) print('User granted provisional permission');
      return true;
    } else {
      if (kDebugMode) print('User declined or has not accepted permission');
      return false;
    }
  }

  Future<void> _updateToken() async {
    if (!_isFirebaseInitialized) {
      return;
    }

    try {
      String? token = await _fcm.getToken();
      if (token != null) {
        if (kDebugMode) print('FCM Token: $token');
        final api = _ref.read(mockApiServiceProvider);
        await api.updateFcmToken(token);
      }
    } catch (e) {
      if (kDebugMode) print('Error getting token: $e');
    }
  }

  Future<void> disableNotifications() async {
    if (!_isFirebaseInitialized) {
      return;
    }

    await _fcm.deleteToken();
    // Also notify backend to remove token if needed
  }
}
