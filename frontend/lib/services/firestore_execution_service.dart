import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/execution_models.dart';
import 'firestore_helper.dart';

class FirestoreExecutionService {
  static Future<CollectionReference> _executionsCollection(
    String orderId,
  ) async {
    final companyRef = await FirestoreHelper.companyRef();
    return companyRef
        .collection('serviceOrders')
        .doc(orderId)
        .collection('executions');
  }

  static Future<ExecutionStartResponse> startExecution({
    required String maintenanceOrderId,
    String? qrCodePayload,
    required String deviceId,
    required double latitude,
    required double longitude,
    double? accuracy,
  }) async {
    final col = await _executionsCollection(maintenanceOrderId);

    // Get the order to fetch checklist items
    final companyRef = await FirestoreHelper.companyRef();
    final orderDoc = await companyRef
        .collection('serviceOrders')
        .doc(maintenanceOrderId)
        .get();

    if (!orderDoc.exists) throw Exception('Service order not found');
    final orderData = orderDoc.data() as Map<String, dynamic>;

    // Extract checklist items from the order
    final checklistData = orderData['checklist'] as Map<String, dynamic>? ?? {};
    final items = (checklistData['itens'] as List? ?? [])
        .map((i) => i as Map<String, dynamic>)
        .toList();

    final data = {
      'maintenanceOrderId': maintenanceOrderId,
      'equipmentId': orderData['equipamentoId'] ?? '',
      'technicianId': FirestoreHelper.uid,
      'deviceId': deviceId,
      'latitude': latitude,
      'longitude': longitude,
      if (accuracy != null) 'accuracy': accuracy,
      if (qrCodePayload != null) 'qrCodePayload': qrCodePayload,
      'status': 'IN_PROGRESS',
      'startedAt': FieldValue.serverTimestamp(),
      'checklistItems': items,
      'orderType': orderData['tipo'] ?? 'MANUTENCAO',
      'problemDescription': orderData['problemDescription'],
    };

    final docRef = await col.add(data);

    // Update order status
    await companyRef.collection('serviceOrders').doc(maintenanceOrderId).update(
      {'status': 'EM_EXECUCAO', 'updatedAt': FieldValue.serverTimestamp()},
    );

    final snap = await docRef.get();
    return ExecutionStartResponse.fromMap(
      snap.data() as Map<String, dynamic>,
      snap.id,
    );
  }

  static Future<ExecutionLookupResponse> lookupExecution({
    String? equipmentCode,
    String? qrCodePayload,
  }) async {
    final companyRef = await FirestoreHelper.companyRef();
    final ordersCol = companyRef.collection('serviceOrders');

    QuerySnapshot snapshot;
    if (equipmentCode != null && equipmentCode.isNotEmpty) {
      snapshot = await ordersCol
          .where('equipamento.codigo', isEqualTo: equipmentCode)
          .where('status', whereIn: ['ABERTA', 'ATRIBUIDA'])
          .limit(1)
          .get();
    } else if (qrCodePayload != null && qrCodePayload.isNotEmpty) {
      String searchCode = qrCodePayload;
      try {
        final decoded = jsonDecode(qrCodePayload);
        if (decoded is Map && decoded.containsKey('qrCode')) {
          searchCode = decoded['qrCode'].toString();
        } else if (decoded is Map && decoded.containsKey('id')) {
          // Fallback to ID if qrCode is missing but ID is present
          searchCode = decoded['id'].toString();
        }
      } catch (_) {
        // Not a JSON, use raw payload
      }

      snapshot = await ordersCol
          .where('equipamento.qrCode', isEqualTo: searchCode)
          .where('status', whereIn: ['ABERTA', 'ATRIBUIDA'])
          .limit(1)
          .get();
    } else {
      throw Exception('Equipment code or QR code required');
    }

    if (snapshot.docs.isEmpty) throw Exception('No matching order found');

    final doc = snapshot.docs.first;
    final data = doc.data() as Map<String, dynamic>;
    return ExecutionLookupResponse.fromMap({
      'maintenanceOrderId': doc.id,
      'maintenanceOrderStatus': data['status'],
      'equipmentId': data['equipamentoId'] ?? '',
      'equipmentName': data['equipamento']?['nome'],
      'equipmentCode': data['equipamento']?['codigo'],
      'clientName': data['cliente']?['nome'],
      'scheduledFor': data['dataPrevista']?.toString(),
      'qrCodePayload': data['equipamento']?['qrCode'] ?? '',
    });
  }

  static Future<ExecutionItemResponse> recordItem({
    required String orderId,
    required String executionId,
    required String checklistItemId,
    required bool status,
    String? observation,
  }) async {
    final col = await _executionsCollection(orderId);
    final itemsCol = col.doc(executionId).collection('items');

    final docRef = await itemsCol.add({
      'checklistItemId': checklistItemId,
      'status': status,
      if (observation != null) 'observation': observation,
      'recordedAt': FieldValue.serverTimestamp(),
    });

    return ExecutionItemResponse.fromMap({}, docRef.id);
  }

  static Future<EvidenceResponse> uploadEvidence({
    required String orderId,
    required String executionId,
    required String checklistExecutionItemId,
    required Uint8List fileBytes,
    required String fileName,
    required String mimeType,
  }) async {
    // Upload to Firebase Storage
    final storagePath = 'evidences/$orderId/$executionId/$fileName';
    final ref = FirebaseStorage.instance.ref(storagePath);
    await ref.putData(fileBytes, SettableMetadata(contentType: mimeType));
    final url = await ref.getDownloadURL();

    // Save reference in Firestore
    final col = await _executionsCollection(orderId);
    final evidencesCol = col.doc(executionId).collection('evidences');
    final docRef = await evidencesCol.add({
      'checklistExecutionItemId': checklistExecutionItemId,
      'url': url,
      'fileName': fileName,
      'mimeType': mimeType,
      'storagePath': storagePath,
      'uploadedAt': FieldValue.serverTimestamp(),
    });

    return EvidenceResponse.fromMap({'url': url}, docRef.id);
  }

  static Future<void> uploadExecutionPhoto({
    required String orderId,
    required String executionId,
    required Uint8List fileBytes,
    required String fileName,
    required String mimeType,
  }) async {
    final storagePath = 'execution_photos/$orderId/$executionId/$fileName';
    final ref = FirebaseStorage.instance.ref(storagePath);
    await ref.putData(fileBytes, SettableMetadata(contentType: mimeType));
    final url = await ref.getDownloadURL();

    final col = await _executionsCollection(orderId);
    await col.doc(executionId).update({
      'photos': FieldValue.arrayUnion([
        {
          'url': url,
          'fileName': fileName,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      ]),
    });
  }

  static Future<void> finalizeExecution({
    required String orderId,
    required String executionId,
    required String signatureBase64,
    String? finalObservation,
  }) async {
    final col = await _executionsCollection(orderId);
    await col.doc(executionId).update({
      'status': 'COMPLETED',
      'signatureBase64': signatureBase64,
      if (finalObservation != null && finalObservation.isNotEmpty)
        'finalObservation': finalObservation,
      'completedAt': FieldValue.serverTimestamp(),
    });

    // Update order status
    final companyRef = await FirestoreHelper.companyRef();
    await companyRef.collection('serviceOrders').doc(orderId).update({
      'status': 'FINALIZADA',
      'dataFinalizacao': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<Uint8List> generateReport({
    required String executionId,
    required String orderId,
  }) async {
    // 1. Fetch Data
    final companyRef = await FirestoreHelper.companyRef();
    final orderDoc = await companyRef
        .collection('serviceOrders')
        .doc(orderId)
        .get();
    final executionDoc = await companyRef
        .collection('serviceOrders')
        .doc(orderId)
        .collection('executions')
        .doc(executionId)
        .get();

    if (!orderDoc.exists || !executionDoc.exists) {
      throw Exception('Dados não encontrados para gerar relatório');
    }

    final order = orderDoc.data() as Map<String, dynamic>;
    final execution = executionDoc.data() as Map<String, dynamic>;

    // Fetch subcollections (items, evidences) if needed, or if they are embedded?
    // In Firestore model, items are usually a subcollection 'items'
    final itemsSnap = await executionDoc.reference.collection('items').get();
    final items = itemsSnap.docs.map((d) => d.data()).toList();

    // 2. Build PDF
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Relatório de Execução',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    'OS: ${_formatOrderId(orderId)}',
                    style: const pw.TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Info Section
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(
                        'Cliente',
                        order['cliente']?['nome'] ?? 'N/A',
                      ),
                      _buildInfoRow(
                        'Equipamento',
                        order['equipamento']?['nome'] ?? 'N/A',
                      ),
                      _buildInfoRow(
                        'Código',
                        order['equipamento']?['codigo'] ?? 'N/A',
                      ),
                    ],
                  ),
                ),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(
                        'Técnico',
                        'Tech Ref $executionId',
                      ), // TODO: fetch updated names
                      _buildInfoRow(
                        'Data Início',
                        _formatDate(execution['startedAt']),
                      ),
                      _buildInfoRow(
                        'Data Fim',
                        _formatDate(execution['completedAt']),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Divider(),

            // Checklist Items
            if (items.isNotEmpty) ...[
              pw.Text(
                'Checklist',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
                context: context,
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.grey300,
                ),
                headers: ['Item', 'Status', 'Observação'],
                data: items.map((item) {
                  // We need item description. It might be in 'checklistItems' array in execution doc or we fetch it.
                  // For simplicity, using ID or if we have embedded data.
                  // The 'startExecution' copied 'checklistItems' (list of maps) to execution doc.
                  // So we should look there for names.
                  // Actually 'items' subcollection has 'checklistItemId'.
                  // To get names we might need to map 'checklistItemId' to names in execution['checklistItems'].
                  final name = _findItemName(
                    item['checklistItemId'],
                    execution['checklistItems'],
                  );
                  final status = item['status'] == true
                      ? 'Conforme'
                      : 'Não Conforme';
                  return [name, status, item['observation'] ?? ''];
                }).toList(),
              ),
              pw.SizedBox(height: 20),
            ],

            // Signatures & Photos would go here
            if (execution['signatureBase64'] != null) ...[
              pw.Text(
                'Assinatura',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              // pw.Image(pw.MemoryImage(base64Decode(execution['signatureBase64']))), // Requires valid base64
            ],
          ];
        },
      ),
    );

    return pdf.save();
  }

  static String _formatOrderId(String id) {
    return id.length > 6 ? id.substring(0, 6).toUpperCase() : id;
  }

  static String _formatDate(dynamic timestamp) {
    if (timestamp == null) return '-';
    if (timestamp is Timestamp)
      return DateFormat('dd/MM/yyyy HH:mm').format(timestamp.toDate());
    return timestamp.toString();
  }

  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        children: [
          pw.Text(
            '$label: ',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(value),
        ],
      ),
    );
  }

  static String _findItemName(String? id, dynamic checklistItems) {
    if (id == null) return '-';
    if (checklistItems is List) {
      final found = checklistItems.firstWhere(
        (e) => e['id'] == id,
        orElse: () => null,
      );
      if (found != null) return found['titulo'] ?? found['item'] ?? id;
    }
    return id;
  }
}
