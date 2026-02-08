import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'; // Needed for ThemeMode and Locale
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../services/google_auth_service.dart';
import '../services/push_notification_service.dart';

class UserProvider with ChangeNotifier {
  static const List<String> _supportedLanguageTags = [
    'en',
    'pt',
    'es',
    'fr',
    'it',
    'de',
    'zh',
    'ko',
    'ja',
  ];
  String? _id;
  String? _token;
  String? _role;
  String? _name;
  String? _email;

  String? get id => _id;
  bool get isAuthenticated => _token != null;
  String? get token => _token;
  String? get role => _role;
  String? get name => _name;
  String? get email => _email;
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;
  Locale _locale = const Locale('en');
  Locale get locale => _locale;

  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDark');
    if (isDark != null) {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    }

    final languageTag = prefs.getString('languageTag');
    final legacyLanguageCode = prefs.getString('languageCode');
    if (languageTag != null) {
      _locale = _localeFromTag(languageTag);
    } else if (legacyLanguageCode != null) {
      _locale = Locale(legacyLanguageCode);
    } else {
      // Auto-detect system language
      final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
      final systemTag = _localeToTag(systemLocale);
      if (_supportedLanguageTags.contains(systemTag)) {
        _locale = systemLocale;
      } else if (_supportedLanguageTags.contains(systemLocale.languageCode)) {
        _locale = Locale(systemLocale.languageCode);
      } else {
        _locale = const Locale('en');
      }
    }
    notifyListeners();
  }

  Future<void> toggleTheme(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDark', isDark);
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    final tag = _localeToTag(locale);
    if (!_supportedLanguageTags.contains(tag) &&
        !_supportedLanguageTags.contains(locale.languageCode)) {
      return;
    }
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageTag', tag);
    await prefs.setString('languageCode', locale.languageCode);
    notifyListeners();
  }

  String _localeToTag(Locale locale) {
    final script = locale.scriptCode;
    if (script != null && script.isNotEmpty) {
      return '${locale.languageCode}-$script';
    }
    return locale.languageCode;
  }

  Locale _localeFromTag(String tag) {
    final parts = tag.split(RegExp('[-_]'));
    if (parts.length == 1) {
      return Locale(parts[0]);
    }
    if (parts.length == 2 && parts[1].length == 4) {
      return Locale.fromSubtags(languageCode: parts[0], scriptCode: parts[1]);
    }
    if (parts.length >= 2) {
      return Locale(parts[0], parts[1]);
    }
    return const Locale('en');
  }

  Future<void> fetchUserProfile() async {
    if (_token == null) return;
    try {
      final data = await ApiService.getUserProfile(_token!);
      _id = data['id']?.toString();
      _name = data['name'];
      _email = data['email'];
      _role = data['role']; // Assuming backend returns role
      // update prefs
      final prefs = await SharedPreferences.getInstance();
      if (_name != null) await prefs.setString('name', _name!);
      if (_email != null) await prefs.setString('email', _email!);
      if (_role != null) await prefs.setString('role', _role!);
      if (_id != null) await prefs.setString('userId', _id!);

      debugPrint('✅ User profile updated: $_name');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Failed to fetch user profile: $e');
      if (e.toString().contains('403') || e.toString().contains('401')) {
        debugPrint('🔒 Token expired or invalid, logging out...');
        logout();
      }
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      debugPrint('🔵 Attempting login for: $email');
      final response = await ApiService.login(email, password);
      _id = response['id']?.toString();
      _token = response['token'];
      _role = response['role'];
      _name = response['name'];

      final prefs = await SharedPreferences.getInstance();
      if (_id != null) await prefs.setString('userId', _id!);
      await prefs.setString('token', _token!);
      await prefs.setString('role', _role!);
      await prefs.setString('name', _name!);
      await prefs.setString('email', email); // Adding email persistence
      _email = email;

      debugPrint('✅ Login successful for: $_name (Role: $_role)');
      notifyListeners();
      PushNotificationService.updateAuthToken(_token);
      // Fetch fresh profile data in background
      fetchUserProfile();
      return true;
    } catch (e) {
      debugPrint('❌ Login failed: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String language,
    String? companyName,
  }) async {
    try {
      debugPrint('🔵 Attempting registration for: $email');
      final response = await ApiService.register(
        name: name,
        email: email,
        password: password,
        language: language,
        companyName: companyName,
      );

      // Auto-login after successful registration
      if (response.containsKey('token')) {
        _id = response['id']?.toString();
        _token = response['token'];
        _role = response['role'];
        _name = response['name'];

        final prefs = await SharedPreferences.getInstance();
        if (_id != null) await prefs.setString('userId', _id!);
        await prefs.setString('token', _token!);
        await prefs.setString('role', _role!);
        await prefs.setString('name', _name!);
        await prefs.setString('email', email);
        _email = email;

        debugPrint('✅ Registration and auto-login successful for: $_name');
        notifyListeners();
        PushNotificationService.updateAuthToken(_token);
      }

      return {'success': true, 'message': 'Account created successfully!'};
    } catch (e) {
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      debugPrint('❌ Registration failed: $errorMessage');
      return {'success': false, 'message': errorMessage};
    }
  }

  /// Sign in with Google
  ///
  /// Returns a map with:
  /// - 'success': bool indicating if sign-in was successful
  /// - 'message': Success or error message
  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      debugPrint('🔵 Starting Google Sign-In process...');
      final googleAuthService = GoogleAuthService();

      // Step 1: Sign in with Google and get Firebase ID token
      final googleResult = await googleAuthService.signInWithGoogle();

      if (!googleResult['success']) {
        debugPrint('❌ Google Sign-In failed in step 1');
        return {
          'success': false,
          'message': googleResult['message'] ?? 'Google sign-in failed',
        };
      }

      final String? idToken = googleResult['idToken'];
      if (idToken == null) {
        debugPrint('❌ Failed to get Firebase ID token');
        return {
          'success': false,
          'message': 'Failed to get authentication token',
        };
      }

      debugPrint('✅ Firebase ID token obtained, sending to backend...');

      // Step 2: Send Firebase ID token to backend
      final response = await ApiService.googleLogin(idToken: idToken);

      // Step 3: Store user data
      _id = response['id']?.toString();
      _token = response['token'];
      _role = response['role'];
      _name = response['name'] ?? googleResult['displayName'];

      final prefs = await SharedPreferences.getInstance();
      if (_id != null) await prefs.setString('userId', _id!);
      await prefs.setString('token', _token!);
      await prefs.setString('role', _role!);
      await prefs.setString('name', _name!);
      // Note: We'd need to extract email from Google result or backend response to save it here.
      // For now, let's assume backend returns it or we get it from googleResult.
      final String? email = response['email'] ?? googleResult['email'];
      if (email != null) {
        await prefs.setString('email', email);
        _email = email;
      }

      debugPrint('✅ Google Sign-In complete for: $_name (Role: $_role)');
      notifyListeners();
      PushNotificationService.updateAuthToken(_token);

      return {
        'success': true,
        'message': 'Successfully signed in with Google!',
      };
    } catch (e) {
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      debugPrint('❌ Google Sign-In error in UserProvider: $errorMessage');
      return {'success': false, 'message': errorMessage};
    }
  }

  Future<void> logout() async {
    _token = null;
    _role = null;
    _name = null;
    _email = null;
    PushNotificationService.updateAuthToken(null);
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }

  Future<void> tryAutoLogin() async {
    await loadPreferences(); // Load theme/lang
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('token')) return;

    _token = prefs.getString('token');
    _role = prefs.getString('role');
    _name = prefs.getString('name');
    _email = prefs.getString('email');
    notifyListeners();
    PushNotificationService.updateAuthToken(_token);

    // Refresh data
    if (_token != null) fetchUserProfile();
  }
}
