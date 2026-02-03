import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class EquipmentService {
  static Future<Map<String, dynamic>> createEquipamento({
    required String token,
    required String nome,
    String? serial,
    String? clienteId,
    String? localizacao,
    double? latitude,
    double? longitude,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/equipamentos'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'nome': nome,
        'codigo': serial,
        'localizacao': localizacao, // Could be address or description
        'latitude': latitude,
        'longitude': longitude,
        if (clienteId != null) 'cliente': {'id': clienteId},
      }),
    );

    print(
      '[EquipmentService.createEquipamento] Response status: ${response.statusCode}',
    );
    print(
      '[EquipmentService.createEquipamento] Response body: ${response.body}',
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Falha ao criar equipamento: ${response.body}');
    }
  }

  static Future<List<Map<String, dynamic>>> getAll({
    required String token,
  }) async {
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/equipamentos'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Falha ao listar equipamentos');
    }
  }

  static Future<Map<String, dynamic>> updateEquipamento({
    required String token,
    required String id,
    required String nome,
    String? serial,
    String? clienteId,
    String? localizacao,
    double? latitude,
    double? longitude,
  }) async {
    final response = await http.put(
      Uri.parse('${ApiService.baseUrl}/equipamentos/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'nome': nome,
        'codigo': serial,
        'localizacao': localizacao,
        'latitude': latitude,
        'longitude': longitude,
        if (clienteId != null) 'cliente': {'id': clienteId},
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Falha ao atualizar equipamento: ${response.body}');
    }
  }

  static Future<void> deleteEquipamento({
    required String token,
    required String id,
  }) async {
    final response = await http.delete(
      Uri.parse('${ApiService.baseUrl}/equipamentos/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Falha ao deletar equipamento: ${response.body}');
    }
  }
}
