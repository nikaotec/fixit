import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class ClienteService {
  static Future<Map<String, dynamic>> criarCliente({
    required String token,
    required String tipo,
    required String nome,
    required String documento,
    String? email,
    String? telefone,
    String? cep,
    String? rua,
    String? numero,
    String? bairro,
    String? cidade,
    String? estado,
    String? complemento,
    String? nomeContato,
    String? cargoContato,
    String? notasInternas,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/api/clientes'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'tipo': tipo,
        'nome': nome,
        'documento': documento,
        if (email != null) 'email': email,
        if (telefone != null) 'telefone': telefone,
        if (cep != null) 'cep': cep,
        if (rua != null) 'rua': rua,
        if (numero != null) 'numero': numero,
        if (bairro != null) 'bairro': bairro,
        if (cidade != null) 'cidade': cidade,
        if (estado != null) 'estado': estado,
        if (complemento != null) 'complemento': complemento,
        if (nomeContato != null) 'nomeContato': nomeContato,
        if (cargoContato != null) 'cargoContato': cargoContato,
        if (notasInternas != null) 'notasInternas': notasInternas,
      }),
    );

    print(
      '[ClienteService.criarCliente] Response status: ${response.statusCode}',
    );
    print('[ClienteService.criarCliente] Response body: ${response.body}');

    if (response.statusCode == 201 || response.statusCode == 200) {
      try {
        return jsonDecode(response.body);
      } catch (e) {
        print('[ClienteService.criarCliente] Error decoding JSON: $e');
        throw Exception(
          'Erro ao processar resposta do servidor: ${response.body}',
        );
      }
    } else if (response.statusCode == 409) {
      final error = jsonDecode(response.body);
      throw DuplicateClientException(
        error['message'] ?? 'Cliente já cadastrado',
        error['conflictId'],
      );
    } else {
      try {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Falha ao criar cliente');
      } catch (e) {
        if (e is DuplicateClientException) rethrow;
        print('[ClienteService.criarCliente] Error decoding error JSON: $e');
        throw Exception(
          'Falha ao criar cliente (Status ${response.statusCode}): ${response.body}',
        );
      }
    }
  }

  static Future<List<Map<String, dynamic>>> listarClientes({
    required String token,
    bool? apenasAtivos,
    String? nome,
    String? tipo,
  }) async {
    var uri = Uri.parse('${ApiService.baseUrl}/api/clientes');

    final queryParams = <String, String>{};
    if (apenasAtivos != null)
      queryParams['apenasAtivos'] = apenasAtivos.toString();
    if (nome != null && nome.isNotEmpty) queryParams['nome'] = nome;
    if (tipo != null) queryParams['tipo'] = tipo;

    if (queryParams.isNotEmpty) {
      uri = uri.replace(queryParameters: queryParams);
    }

    print('[ClienteService.listarClientes] Fetching from: $uri');
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    print(
      '[ClienteService.listarClientes] Response status: ${response.statusCode}',
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Falha ao listar clientes');
    }
  }

  static Future<Map<String, dynamic>> buscarCliente({
    required String token,
    required String id,
  }) async {
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/api/clientes/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Cliente não encontrado');
    }
  }

  static Future<Map<String, dynamic>> atualizarCliente({
    required String token,
    required String id,
    required String tipo,
    required String nome,
    required String documento,
    String? email,
    String? telefone,
    String? cep,
    String? rua,
    String? numero,
    String? bairro,
    String? cidade,
    String? estado,
    String? complemento,
    String? nomeContato,
    String? cargoContato,
    String? notasInternas,
  }) async {
    final response = await http.put(
      Uri.parse('${ApiService.baseUrl}/api/clientes/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'tipo': tipo,
        'nome': nome,
        'documento': documento,
        if (email != null) 'email': email,
        if (telefone != null) 'telefone': telefone,
        if (cep != null) 'cep': cep,
        if (rua != null) 'rua': rua,
        if (numero != null) 'numero': numero,
        if (bairro != null) 'bairro': bairro,
        if (cidade != null) 'cidade': cidade,
        if (estado != null) 'estado': estado,
        if (complemento != null) 'complemento': complemento,
        if (nomeContato != null) 'nomeContato': nomeContato,
        if (cargoContato != null) 'cargoContato': cargoContato,
        if (notasInternas != null) 'notasInternas': notasInternas,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Falha ao atualizar cliente');
    }
  }

  static Future<void> desativarCliente({
    required String token,
    required String id,
  }) async {
    final response = await http.patch(
      Uri.parse('${ApiService.baseUrl}/api/clientes/$id/desativar'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 204) {
      throw Exception('Falha ao desativar cliente');
    }
  }

  static Future<void> deletarCliente({
    required String token,
    required String id,
  }) async {
    final response = await http.delete(
      Uri.parse('${ApiService.baseUrl}/api/clientes/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 204) {
      throw Exception('Falha ao deletar cliente');
    }
  }
}

class DuplicateClientException implements Exception {
  final String message;
  final String? conflictId;

  DuplicateClientException(this.message, this.conflictId);

  @override
  String toString() => message;
}
