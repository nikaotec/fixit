import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../models/execution_models.dart';
import 'api_service.dart';

class ExecutionService {
  static Future<ExecutionStartResponse> startExecution({
    required String token,
    required int maintenanceOrderId,
    String? qrCodePayload,
    required String deviceId,
    required double latitude,
    required double longitude,
    double? accuracy,
  }) async {
    if (kDebugMode) {
      final preview = token.length > 10 ? token.substring(0, 10) : token;
      debugPrint('ExecutionService.startExecution token: $preview...');
    }
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/executions/start'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'maintenanceOrderId': maintenanceOrderId,
        if (qrCodePayload != null && qrCodePayload.isNotEmpty)
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
    String message = 'Failed to start execution: ${response.statusCode}';
    try {
      final data = jsonDecode(response.body);
      if (data is Map) {
        if (data['message'] != null) {
          message = data['message'].toString();
        } else if (data.isNotEmpty) {
          final parts = <String>[];
          data.forEach((key, value) {
            parts.add('$key: $value');
          });
          message = parts.join(' • ');
        }
      }
    } catch (_) {}
    throw Exception(message);
  }

  static Future<ExecutionLookupResponse> lookupExecution({
    required String token,
    String? equipmentCode,
    String? qrCodePayload,
  }) async {
    if (kDebugMode) {
      final preview = token.length > 10 ? token.substring(0, 10) : token;
      debugPrint('ExecutionService.lookupExecution token: $preview...');
    }
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/executions/lookup'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        if (equipmentCode != null && equipmentCode.isNotEmpty)
          'equipmentCode': equipmentCode,
        if (qrCodePayload != null && qrCodePayload.isNotEmpty)
          'qrCodePayload': qrCodePayload,
      }),
    );

    if (response.statusCode == 200) {
      return ExecutionLookupResponse.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to lookup execution: ${response.statusCode}');
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

  static Future<void> uploadExecutionPhoto({
    required String token,
    required int executionId,
    required Uint8List fileBytes,
    required String fileName,
    required String mimeType,
  }) async {
    final uri = Uri.parse('${ApiService.baseUrl}/executions/$executionId/photos/upload');
    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';

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
    if (response.statusCode != 200) {
      throw Exception('Failed to upload execution photo: ${response.statusCode}');
    }
  }

  static Future<void> finalizeExecution({
    required String token,
    required int executionId,
    required String signatureBase64,
    String? finalObservation,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/executions/$executionId/finalize'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'signatureBase64': signatureBase64,
        if (finalObservation != null && finalObservation.isNotEmpty)
          'finalObservation': finalObservation,
      }),
    );

    if (response.statusCode != 200) {
      String message = 'Failed to finalize execution: ${response.statusCode}';
      try {
        final data = jsonDecode(response.body);
        if (data is Map && data['message'] != null) {
          message = data['message'].toString();
        }
      } catch (_) {}
      throw Exception(message);
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
