class Order {
  final int id;
  final String status;
  final String priority;
  final Equipamento equipamento;
  final Checklist checklist;

  Order({
    required this.id,
    required this.status,
    required this.priority,
    required this.equipamento,
    required this.checklist,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      status: json['status'],
      priority: json['priority'],
      equipamento: Equipamento.fromJson(json['equipamento']),
      checklist: Checklist.fromJson(json['checklist']),
    );
  }
}

class Equipamento {
  final int id;
  final String nome;
  final String codigo;
  final String qrCode;

  Equipamento({
    required this.id,
    required this.nome,
    required this.codigo,
    required this.qrCode,
  });

  factory Equipamento.fromJson(Map<String, dynamic> json) {
    return Equipamento(
      id: json['id'],
      nome: json['nome'],
      codigo: json['codigo'],
      qrCode: json['qrCode'],
    );
  }
}

class Checklist {
  final int id;
  final String nome;
  final List<ChecklistItem> itens;

  Checklist({required this.id, required this.nome, required this.itens});

  factory Checklist.fromJson(Map<String, dynamic> json) {
    var list = json['itens'] as List;
    List<ChecklistItem> itemsList = list
        .map((i) => ChecklistItem.fromJson(i))
        .toList();
    return Checklist(id: json['id'], nome: json['nome'], itens: itemsList);
  }
}

class ChecklistItem {
  final int id;
  final String descricao;
  final bool obrigatorioFoto;

  ChecklistItem({
    required this.id,
    required this.descricao,
    required this.obrigatorioFoto,
  });

  factory ChecklistItem.fromJson(Map<String, dynamic> json) {
    return ChecklistItem(
      id: json['id'],
      descricao: json['descricao'],
      obrigatorioFoto: json['obrigatorioFoto'],
    );
  }
}
