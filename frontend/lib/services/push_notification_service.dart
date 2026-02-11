import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'local_notification_service.dart';

class PushNotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized || kIsWeb) return;
    _initialized = true;

    await _messaging.requestPermission(alert: true, badge: true, sound: true);
    if (Platform.isIOS) {
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    FirebaseMessaging.onMessage.listen((message) {
      if (!Platform.isAndroid) return;
      final notification = message.notification;
      if (notification == null) return;
      LocalNotificationService.show(
        id: notification.hashCode,
        title: notification.title ?? 'Nova notificacao',
        body: notification.body ?? '',
      );
    });

    _messaging.onTokenRefresh.listen((token) {
      _saveTokenToFirestore(token);
    });

    // Initial token save
    final token = await _messaging.getToken();
    if (token != null) {
      _saveTokenToFirestore(token);
    }
  }

  // No longer needed as we use FirebaseAuth
  static Future<void> updateAuthToken(String? token) async {
    // no-op, kept for compatibility if called from elsewhere until cleaned up
  }

  static Future<void> _saveTokenToFirestore(String token) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'fcmToken': token,
        'updatedAt': FieldValue.serverTimestamp(),
        if (user.displayName != null) 'name': user.displayName,
        if (user.email != null) 'email': user.email,
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('❌ Falha ao salvar FCM token no Firestore: $e');
    }
  }
}
