import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class DeviceService {
  static const _deviceIdKey = 'device_id';

  static Future<String> getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_deviceIdKey);
    if (stored != null && stored.isNotEmpty) {
      return stored;
    }

    final deviceInfo = DeviceInfoPlugin();
    String deviceId = 'unknown-device';

    if (kIsWeb) {
      deviceId = 'web-${DateTime.now().millisecondsSinceEpoch}';
    } else {
      try {
        final info = await deviceInfo.deviceInfo;
        deviceId = info.data['id']?.toString() ??
            info.data['identifierForVendor']?.toString() ??
            info.data['androidId']?.toString() ??
            'device-${DateTime.now().millisecondsSinceEpoch}';
      } catch (_) {
        deviceId = 'device-${DateTime.now().millisecondsSinceEpoch}';
      }
    }

    await prefs.setString(_deviceIdKey, deviceId);
    return deviceId;
  }
}
