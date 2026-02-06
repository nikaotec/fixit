class ExecutionStartResponse {
  final int executionId;
  final int maintenanceOrderId;
  final int equipmentId;
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

  factory ExecutionStartResponse.fromJson(Map<String, dynamic> json) {
    final items = (json['checklistItems'] as List? ?? [])
        .map((item) => ExecutionChecklistItem.fromJson(item))
        .toList();
    return ExecutionStartResponse(
      executionId: json['executionId'],
      maintenanceOrderId: json['maintenanceOrderId'],
      equipmentId: json['equipmentId'] ?? 0,
      checklistItems: items,
      orderType: json['orderType'] ?? json['tipo'] ?? 'MANUTENCAO',
      problemDescription: json['problemDescription'],
    );
  }
}

class ExecutionLookupResponse {
  final int maintenanceOrderId;
  final String? maintenanceOrderStatus;
  final int equipmentId;
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

  factory ExecutionLookupResponse.fromJson(Map<String, dynamic> json) {
    return ExecutionLookupResponse(
      maintenanceOrderId: json['maintenanceOrderId'],
      maintenanceOrderStatus: json['maintenanceOrderStatus'],
      equipmentId: json['equipmentId'],
      equipmentName: json['equipmentName'],
      equipmentCode: json['equipmentCode'],
      clientName: json['clientName'],
      scheduledFor: json['scheduledFor'],
      qrCodePayload: json['qrCodePayload'] ?? '',
    );
  }
}

class ExecutionChecklistItem {
  final int id;
  final String descricao;
  final bool obrigatorioFoto;
  final bool critico;

  ExecutionChecklistItem({
    required this.id,
    required this.descricao,
    required this.obrigatorioFoto,
    required this.critico,
  });

  factory ExecutionChecklistItem.fromJson(Map<String, dynamic> json) {
    return ExecutionChecklistItem(
      id: json['id'],
      descricao: json['descricao'],
      obrigatorioFoto: json['obrigatorioFoto'] ?? false,
      critico: json['critico'] ?? false,
    );
  }
}

class ExecutionItemResponse {
  final int id;

  ExecutionItemResponse({required this.id});

  factory ExecutionItemResponse.fromJson(Map<String, dynamic> json) {
    return ExecutionItemResponse(id: json['id']);
  }
}

class EvidenceResponse {
  final int id;
  final String url;

  EvidenceResponse({required this.id, required this.url});

  factory EvidenceResponse.fromJson(Map<String, dynamic> json) {
    return EvidenceResponse(id: json['id'], url: json['url']);
  }
}
