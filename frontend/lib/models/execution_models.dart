import 'package:cloud_firestore/cloud_firestore.dart' hide Order;

class ExecutionStartResponse {
  final String executionId;
  final String maintenanceOrderId;
  final String equipmentId;
  final List<ExecutionChecklistItem> checklistItems;
  final String orderType;
  final String? problemDescription;

  ExecutionStartResponse({
    required this.executionId,
    required this.maintenanceOrderId,
    required this.equipmentId,
    required this.checklistItems,
    required this.orderType,
    this.problemDescription,
  });

  factory ExecutionStartResponse.fromMap(
    Map<String, dynamic> map,
    String docId,
  ) {
    final items = (map['checklistItems'] as List? ?? [])
        .map(
          (item) =>
              ExecutionChecklistItem.fromMap(item as Map<String, dynamic>),
        )
        .toList();
    return ExecutionStartResponse(
      executionId: docId,
      maintenanceOrderId: map['maintenanceOrderId']?.toString() ?? '',
      equipmentId: map['equipmentId']?.toString() ?? '',
      checklistItems: items,
      orderType: map['orderType'] ?? map['tipo'] ?? 'MANUTENCAO',
      problemDescription: map['problemDescription'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'maintenanceOrderId': maintenanceOrderId,
      'equipmentId': equipmentId,
      'checklistItems': checklistItems.map((i) => i.toMap()).toList(),
      'orderType': orderType,
      if (problemDescription != null) 'problemDescription': problemDescription,
      'startedAt': FieldValue.serverTimestamp(),
    };
  }
}

class ExecutionLookupResponse {
  final String maintenanceOrderId;
  final String? maintenanceOrderStatus;
  final String equipmentId;
  final String? equipmentName;
  final String? equipmentCode;
  final String? clientName;
  final String? scheduledFor;
  final String qrCodePayload;

  ExecutionLookupResponse({
    required this.maintenanceOrderId,
    required this.maintenanceOrderStatus,
    required this.equipmentId,
    required this.equipmentName,
    required this.equipmentCode,
    required this.clientName,
    required this.scheduledFor,
    required this.qrCodePayload,
  });

  factory ExecutionLookupResponse.fromMap(Map<String, dynamic> map) {
    return ExecutionLookupResponse(
      maintenanceOrderId: map['maintenanceOrderId']?.toString() ?? '',
      maintenanceOrderStatus: map['maintenanceOrderStatus'],
      equipmentId: map['equipmentId']?.toString() ?? '',
      equipmentName: map['equipmentName'],
      equipmentCode: map['equipmentCode'],
      clientName: map['clientName'],
      scheduledFor: map['scheduledFor'],
      qrCodePayload: map['qrCodePayload'] ?? '',
    );
  }
}

class ExecutionChecklistItem {
  final String id;
  final String descricao;
  final bool obrigatorioFoto;
  final bool critico;

  ExecutionChecklistItem({
    required this.id,
    required this.descricao,
    required this.obrigatorioFoto,
    required this.critico,
  });

  factory ExecutionChecklistItem.fromMap(Map<String, dynamic> map) {
    return ExecutionChecklistItem(
      id: map['id']?.toString() ?? '',
      descricao: map['descricao'] ?? '',
      obrigatorioFoto: map['obrigatorioFoto'] ?? false,
      critico: map['critico'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'descricao': descricao,
      'obrigatorioFoto': obrigatorioFoto,
      'critico': critico,
    };
  }
}

class ExecutionItemResponse {
  final String id;

  ExecutionItemResponse({required this.id});

  factory ExecutionItemResponse.fromMap(
    Map<String, dynamic> map,
    String docId,
  ) {
    return ExecutionItemResponse(id: docId);
  }
}

class EvidenceResponse {
  final String id;
  final String url;

  EvidenceResponse({required this.id, required this.url});

  factory EvidenceResponse.fromMap(Map<String, dynamic> map, String docId) {
    return EvidenceResponse(id: docId, url: map['url'] ?? '');
  }
}
