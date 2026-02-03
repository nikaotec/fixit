import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/order.dart';
import 'api_service.dart';

class ChecklistService {
  static Future<List<Checklist>> getAll({required String token}) async {
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/checklists'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Checklist.fromJson(e)).toList();
    }
    throw Exception('Falha ao listar checklists: ${response.statusCode}');
  }

  static Future<Checklist> create({
    required String token,
    required String nome,
    String? descricao,
    required List<Map<String, dynamic>> itens,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/checklists'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'nome': nome,
        'descricao': descricao,
        'itens': itens,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Checklist.fromJson(jsonDecode(response.body));
    }
    throw Exception('Falha ao criar checklist: ${response.statusCode}');
  }
}
