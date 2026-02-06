import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/order.dart';
import 'api_service.dart';

class OrderService {
  static Future<List<Order>> getAll({required String token}) async {
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/ordens'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Order.fromJson(e)).toList();
    }
    throw Exception('Falha ao listar ordens: ${response.statusCode}');
  }

  static Future<Order> create({
    required String token,
    int? equipamentoId,
    int? checklistId,
    String? clienteId,
    String? responsavelId,
    required String prioridade,
    required String orderType,
    String? problemDescription,
    String? equipmentBrand,
    String? equipmentModel,
    DateTime? dataPrevista,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/ordens'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        if (equipamentoId != null) 'equipamento': {'id': equipamentoId},
        if (checklistId != null) 'checklist': {'id': checklistId},
        if (clienteId != null) 'cliente': {'id': clienteId},
        if (responsavelId != null) 'responsavel': {'id': responsavelId},
        'prioridade': prioridade,
        'tipo': orderType,
        if (problemDescription != null && problemDescription.trim().isNotEmpty)
          'problemDescription': problemDescription.trim(),
        if (equipmentBrand != null && equipmentBrand.trim().isNotEmpty)
          'equipmentBrand': equipmentBrand.trim(),
        if (equipmentModel != null && equipmentModel.trim().isNotEmpty)
          'equipmentModel': equipmentModel.trim(),
        if (dataPrevista != null) 'dataPrevista': dataPrevista.toIso8601String(),
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Order.fromJson(jsonDecode(response.body));
    }
    throw Exception('Falha ao criar ordem: ${response.statusCode}');
  }

  static Future<Order> getById({required String token, required int id}) async {
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/ordens/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return Order.fromJson(jsonDecode(response.body));
    }
    throw Exception('Falha ao buscar ordem: ${response.statusCode}');
  }
}
