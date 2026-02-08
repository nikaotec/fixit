import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/order.dart';

class ApiService {
  static String get baseUrl {
    const String baseUrlOverride = String.fromEnvironment('API_BASE_URL');
    const String hostOverride = String.fromEnvironment('API_HOST');
    const String portOverride = String.fromEnvironment(
      'API_PORT',
      defaultValue: '8080',
    );
    final String dotenvBaseUrl = dotenv.env['API_BASE_URL'] ?? '';
    final String dotenvHost = dotenv.env['API_HOST'] ?? '';
    final String dotenvPort = dotenv.env['API_PORT'] ?? '8080';

    if (baseUrlOverride.isNotEmpty) {
      return baseUrlOverride;
    }

    if (hostOverride.isNotEmpty) {
      return 'http://$hostOverride:$portOverride';
    }

    if (dotenvBaseUrl.isNotEmpty) {
      return dotenvBaseUrl;
    }

    if (dotenvHost.isNotEmpty) {
      return 'http://$dotenvHost:$dotenvPort';
    }

    if (kIsWeb) {
      return 'http://localhost:8080';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:8080';
    } else {
      return 'http://localhost:8080';
    }
  }

  static String get wsBaseUrl {
    return baseUrl.replaceFirst('http', 'ws');
  }

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to login');
    }
  }

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String language,
    String? companyName,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'language': language,
        if (companyName != null && companyName.isNotEmpty)
          'companyName': companyName,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to register');
    }
  }

  /// Login with Google using Firebase ID token
  static Future<Map<String, dynamic>> googleLogin({
    required String idToken,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/google-login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'idToken': idToken}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to authenticate with Google');
    }
  }

  static Future<Map<String, dynamic>> getUserProfile(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch user profile: ${response.statusCode}');
    }
  }

  static Future<void> registerFcmToken({
    required String token,
    required String fcmToken,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/me/fcm-token'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'token': fcmToken}),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to register FCM token: ${response.statusCode}');
    }
  }

  static Future<void> registerApnsToken({
    required String token,
    required String apnsToken,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/me/apns-token'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'token': apnsToken}),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to register APNS token: ${response.statusCode}');
    }
  }

  static Future<List<Order>> fetchOrders() async {
    // Need to get token here
    // For MVP simplicity using hardcoded or handled via interceptor in real app
    // Assuming unauthenticated for initial scan or retrieving stored token

    // WARNING: In a real app, inject the token into headers.
    // final prefs = await SharedPreferences.getInstance();
    // final token = prefs.getString('token');

    // For now mocking empty or error if no token logic implemented in ApiService
    // Return mock data for MVP UI testing if backend not reachable via localhost loops
    return [];
  }
}
