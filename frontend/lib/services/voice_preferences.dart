import 'package:shared_preferences/shared_preferences.dart';

class VoicePreferences {
  static const _key = 'voice_locale';

  static Future<String?> getLocale() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }

  static Future<void> setLocale(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, value);
  }
}
