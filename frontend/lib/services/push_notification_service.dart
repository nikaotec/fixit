import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'api_service.dart';
import 'local_notification_service.dart';

class PushNotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static bool _initialized = false;
  static String? _authToken;

  static Future<void> initialize() async {
    if (_initialized || kIsWeb) return;
    _initialized = true;

    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
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
      _sendToken(token);
    });

    if (_authToken != null) {
      if (Platform.isAndroid) {
        final token = await _messaging.getToken();
        if (token != null) {
          await _sendToken(token);
        }
      }
      await _sendApnsToken();
    }
  }

  static Future<void> updateAuthToken(String? token) async {
    _authToken = token;
    if (_authToken == null || kIsWeb) return;
    if (Platform.isAndroid) {
      final fcmToken = await _messaging.getToken();
      if (fcmToken != null) {
        await _sendToken(fcmToken);
      }
    }
    await _sendApnsToken();
  }

  static Future<void> _sendToken(String fcmToken) async {
    final auth = _authToken;
    if (auth == null) return;
    try {
      await ApiService.registerFcmToken(token: auth, fcmToken: fcmToken);
    } catch (e) {
      debugPrint('❌ Falha ao registrar FCM token: $e');
    }
  }

  static Future<void> _sendApnsToken() async {
    if (kIsWeb || !Platform.isIOS) return;
    final auth = _authToken;
    if (auth == null) return;
    try {
      final apnsToken = await _messaging.getAPNSToken();
      if (apnsToken == null || apnsToken.isEmpty) return;
      await ApiService.registerApnsToken(token: auth, apnsToken: apnsToken);
    } catch (e) {
      debugPrint('❌ Falha ao registrar APNS token: $e');
    }
  }
}
