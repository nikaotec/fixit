import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../models/execution_models.dart';
import 'api_service.dart';

class ExecutionService {
  static Future<ExecutionStartResponse> startExecution({
    required String token,
    required int maintenanceOrderId,
    required String qrCodePayload,
    required String deviceId,
    required double latitude,
    required double longitude,
    double? accuracy,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/executions/start'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'maintenanceOrderId': maintenanceOrderId,
        'qrCodePayload': qrCodePayload,
        'deviceId': deviceId,
        'latitude': latitude,
        'longitude': longitude,
        'accuracy': accuracy,
      }),
    );

    if (response.statusCode == 200) {
      return ExecutionStartResponse.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to start execution: ${response.statusCode}');
  }

  static Future<ExecutionItemResponse> recordItem({
    required String token,
    required int executionId,
    required int checklistItemId,
    required bool status,
    String? observation,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/executions/$executionId/items'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'checklistItemId': checklistItemId,
        'status': status,
        'observation': observation,
      }),
    );

    if (response.statusCode == 200) {
      return ExecutionItemResponse.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to record item: ${response.statusCode}');
  }

  static Future<EvidenceResponse> uploadEvidence({
    required String token,
    required int checklistExecutionItemId,
    required Uint8List fileBytes,
    required String fileName,
    required String mimeType,
  }) async {
    final uri = Uri.parse('${ApiService.baseUrl}/executions/evidences/upload');
    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['checklistExecutionItemId'] = checklistExecutionItemId.toString();

    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        fileBytes,
        filename: fileName,
        contentType: MediaType.parse(mimeType),
      ),
    );

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode == 200) {
      return EvidenceResponse.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to upload evidence: ${response.statusCode}');
  }

  static Future<void> finalizeExecution({
    required String token,
    required int executionId,
    required String signatureBase64,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/executions/$executionId/finalize'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'signatureBase64': signatureBase64}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to finalize execution: ${response.statusCode}');
    }
  }

  static Future<Uint8List> downloadReport({
    required String token,
    required int executionId,
  }) async {
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/executions/$executionId/report'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return response.bodyBytes;
    }
    throw Exception('Failed to download report: ${response.statusCode}');
  }
}
