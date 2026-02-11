import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _role;
  String? _name;
  String? _email;
  String? _companyId;

  String? get id => _auth.currentUser?.uid;
  bool get isAuthenticated => _auth.currentUser != null;
  String? get role => _role;
  String? get name => _name ?? _auth.currentUser?.displayName;
  String? get email => _email ?? _auth.currentUser?.email;
  String? get photoURL => _auth.currentUser?.photoURL;
  String? get companyId => _companyId;

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
    if (parts.length == 1) return Locale(parts[0]);
    if (parts.length == 2 && parts[1].length == 4) {
      return Locale.fromSubtags(languageCode: parts[0], scriptCode: parts[1]);
    }
    if (parts.length >= 2) return Locale(parts[0], parts[1]);
    return const Locale('en');
  }

  Future<void> fetchUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        _name = data['name'] ?? user.displayName;
        _email = data['email'] ?? user.email;
        _role = data['role'] ?? 'TECHNICIAN';
        _companyId = data['companyId'];

        if (_companyId == null) {
          // If user exists but has no company, create one
          final companyDoc = await _firestore.collection('companies').add({
            'name': '${_name ?? "Minha"}\'s Company',
            'createdAt': FieldValue.serverTimestamp(),
            'ownerId': user.uid,
          });
          _companyId = companyDoc.id;
          await _firestore.collection('users').doc(user.uid).update({
            'companyId': _companyId,
          });
        }
      } else {
        // Self-Healing: Create missing profile and company
        final companyDoc = await _firestore.collection('companies').add({
          'name': '${user.displayName ?? "Minha"}\'s Company',
          'createdAt': FieldValue.serverTimestamp(),
          'ownerId': user.uid,
        });
        _companyId = companyDoc.id;
        _name = user.displayName;
        _email = user.email;
        _role = 'ADMIN';

        await _firestore.collection('users').doc(user.uid).set({
          'name': _name ?? '',
          'email': _email ?? '',
          'role': _role,
          'companyId': _companyId,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      final prefs = await SharedPreferences.getInstance();
      if (_name != null) await prefs.setString('name', _name!);
      if (_email != null) await prefs.setString('email', _email!);
      if (_role != null) await prefs.setString('role', _role!);
      if (_companyId != null) await prefs.setString('companyId', _companyId!);

      notifyListeners();
    } catch (e) {
      debugPrint('Failed to fetch user profile: $e');
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      await fetchUserProfile();
      PushNotificationService.initialize();
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint('Login failed: ${e.code}');
      return false;
    } catch (e) {
      debugPrint('Login failed: $e');
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
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await credential.user?.updateDisplayName(name);

      // Create or find company
      String companyId;
      if (companyName != null && companyName.isNotEmpty) {
        final companyDoc = await _firestore.collection('companies').add({
          'name': companyName,
          'createdAt': FieldValue.serverTimestamp(),
          'ownerId': credential.user!.uid,
        });
        companyId = companyDoc.id;
      } else {
        // Create personal company
        final companyDoc = await _firestore.collection('companies').add({
          'name': '$name\'s Company',
          'createdAt': FieldValue.serverTimestamp(),
          'ownerId': credential.user!.uid,
        });
        companyId = companyDoc.id;
      }

      // Create user document in Firestore
      await _firestore.collection('users').doc(credential.user!.uid).set({
        'name': name,
        'email': email,
        'role': 'ADMIN',
        'companyId': companyId,
        'language': language,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _name = name;
      _email = email;
      _role = 'ADMIN';
      _companyId = companyId;

      PushNotificationService.initialize();
      notifyListeners();

      return {'success': true, 'message': 'Account created successfully!'};
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'message': e.message ?? 'Registration failed'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      final googleAuthService = GoogleAuthService();
      final result = await googleAuthService.signInWithGoogle();

      if (!result['success']) {
        return {
          'success': false,
          'message': result['message'] ?? 'Google sign-in failed',
        };
      }

      final user = _auth.currentUser;
      if (user == null) {
        return {'success': false, 'message': 'Authentication failed'};
      }

      // Check if user document exists
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        // First-time Google user — create company and user document
        final companyDoc = await _firestore.collection('companies').add({
          'name': '${user.displayName ?? "My"}\'s Company',
          'createdAt': FieldValue.serverTimestamp(),
          'ownerId': user.uid,
        });

        await _firestore.collection('users').doc(user.uid).set({
          'name': user.displayName ?? '',
          'email': user.email ?? '',
          'role': 'ADMIN',
          'companyId': companyDoc.id,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      await fetchUserProfile();
      PushNotificationService.initialize();

      return {
        'success': true,
        'message': 'Successfully signed in with Google!',
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<void> logout() async {
    try {
      await GoogleAuthService().signOut();
    } catch (_) {}
    await _auth.signOut();

    _role = null;
    _name = null;
    _email = null;
    _companyId = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }

  Future<void> tryAutoLogin() async {
    await loadPreferences();

    final user = _auth.currentUser;
    if (user == null) return;

    // Load cached data from preferences
    final prefs = await SharedPreferences.getInstance();
    _name = prefs.getString('name') ?? user.displayName;
    _email = prefs.getString('email') ?? user.email;
    _role = prefs.getString('role');
    _companyId = prefs.getString('companyId');

    notifyListeners();
    PushNotificationService.initialize();

    // Refresh from Firestore in background
    fetchUserProfile();
  }
}
