import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class NotificationService {
  static Future<List<Map<String, dynamic>>> getAll({
    required String token,
  }) async {
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/notifications'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    }
    throw Exception('Falha ao listar notificações: ${response.statusCode}');
  }
}
