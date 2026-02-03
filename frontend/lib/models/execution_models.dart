class ExecutionStartResponse {
  final int executionId;
  final int maintenanceOrderId;
  final int equipmentId;
  final List<ExecutionChecklistItem> checklistItems;

  ExecutionStartResponse({
    required this.executionId,
    required this.maintenanceOrderId,
    required this.equipmentId,
    required this.checklistItems,
  });

  factory ExecutionStartResponse.fromJson(Map<String, dynamic> json) {
    final items = (json['checklistItems'] as List)
        .map((item) => ExecutionChecklistItem.fromJson(item))
        .toList();
    return ExecutionStartResponse(
      executionId: json['executionId'],
      maintenanceOrderId: json['maintenanceOrderId'],
      equipmentId: json['equipmentId'],
      checklistItems: items,
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
