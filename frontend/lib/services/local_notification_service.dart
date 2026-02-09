import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;
  static const String _channelId = 'orders_channel';
  static const String _channelName = 'Ordens de Servico';
  static const String _channelDescription =
      'Notificacoes de ordens e atribuicoes';

  static Future<void> initialize() async {
    if (_initialized) return;
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('ic_notification'),
      iOS: iosSettings,
    );
    try {
      await _plugin.initialize(settings);
    } on PlatformException catch (e) {
      if (e.code != 'invalid_icon') rethrow;
      const fallbackSettings = InitializationSettings(
        android: AndroidInitializationSettings('ic_launcher'),
        iOS: iosSettings,
      );
      await _plugin.initialize(fallbackSettings);
    }
    await _createAndroidChannel();
    _initialized = true;
  }

  static Future<void> show({
    required int id,
    required String title,
    required String body,
  }) async {
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: const DarwinNotificationDetails(),
    );
    await _plugin.show(id, title, body, details);
  }

  static Future<void> _createAndroidChannel() async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
    );
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(channel);
  }
}
