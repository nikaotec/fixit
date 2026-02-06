class Order {
  final int id;
  final String status;
  final String priority;
  final String orderType;
  final String? problemDescription;
  final String? equipmentBrand;
  final String? equipmentModel;
  final Equipamento equipamento;
  final Checklist checklist;
  final Cliente? cliente;
  final UserSummary? criador;
  final UserSummary? responsavel;
  final DateTime? dataPrevista;
  final DateTime? dataCriacao;
  final DateTime? dataFinalizacao;

  Order({
    required this.id,
    required this.status,
    required this.priority,
    required this.orderType,
    this.problemDescription,
    this.equipmentBrand,
    this.equipmentModel,
    required this.equipamento,
    required this.checklist,
    this.cliente,
    this.criador,
    this.responsavel,
    this.dataPrevista,
    this.dataCriacao,
    this.dataFinalizacao,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      status: json['status'],
      priority: json['prioridade'] ?? json['priority'] ?? 'MEDIA',
      orderType: json['tipo'] ?? json['orderType'] ?? 'MANUTENCAO',
      problemDescription: json['problemDescription'],
      equipmentBrand: json['equipmentBrand'],
      equipmentModel: json['equipmentModel'],
      equipamento: Equipamento.fromJson(json['equipamento'] ?? {}),
      checklist: Checklist.fromJson(json['checklist'] ?? {}),
      cliente:
          json['cliente'] != null ? Cliente.fromJson(json['cliente']) : null,
      criador:
          json['criador'] != null ? UserSummary.fromJson(json['criador']) : null,
      responsavel: json['responsavel'] != null
          ? UserSummary.fromJson(json['responsavel'])
          : null,
      dataPrevista: _parseDate(json['dataPrevista']),
      dataCriacao: _parseDate(json['dataCriacao']),
      dataFinalizacao: _parseDate(json['dataFinalizacao']),
    );
  }
}

class Equipamento {
  final int id;
  final String nome;
  final String codigo;
  final String qrCode;
  final String? localizacao;
  final double? latitude;
  final double? longitude;
  final Cliente? cliente;

  Equipamento({
    required this.id,
    required this.nome,
    required this.codigo,
    required this.qrCode,
    this.localizacao,
    this.latitude,
    this.longitude,
    this.cliente,
  });

  factory Equipamento.fromJson(Map<String, dynamic> json) {
    return Equipamento(
      id: json['id'] ?? 0,
      nome: json['nome'] ?? '',
      codigo: json['codigo'] ?? '',
      qrCode: json['qrCode'] ?? '',
      localizacao: json['localizacao'],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      cliente:
          json['cliente'] != null ? Cliente.fromJson(json['cliente']) : null,
    );
  }
}

class Checklist {
  final int id;
  final String nome;
  final List<ChecklistItem> itens;
  final String? descricao;
  final int? versao;
  final bool? ativo;

  Checklist({
    required this.id,
    required this.nome,
    required this.itens,
    this.descricao,
    this.versao,
    this.ativo,
  });

  factory Checklist.fromJson(Map<String, dynamic> json) {
    var list = (json['itens'] ?? []) as List;
    List<ChecklistItem> itemsList = list
        .map((i) => ChecklistItem.fromJson(i))
        .toList();
    return Checklist(
      id: json['id'] ?? 0,
      nome: json['nome'] ?? '',
      itens: itemsList,
      descricao: json['descricao'],
      versao: json['versao'],
      ativo: json['ativo'],
    );
  }
}

class ChecklistItem {
  final int id;
  final String descricao;
  final bool obrigatorioFoto;
  final bool critico;

  ChecklistItem({
    required this.id,
    required this.descricao,
    required this.obrigatorioFoto,
    required this.critico,
  });

  factory ChecklistItem.fromJson(Map<String, dynamic> json) {
    return ChecklistItem(
      id: json['id'],
      descricao: json['descricao'],
      obrigatorioFoto: json['obrigatorioFoto'] ?? false,
      critico: json['critico'] ?? false,
    );
  }
}

class Cliente {
  final String id;
  final String nome;
  final String? email;
  final String? tipo;
  final String? cidade;
  final String? estado;
  final String? rua;
  final String? numero;
  final String? bairro;

  Cliente({
    required this.id,
    required this.nome,
    this.email,
    this.tipo,
    this.cidade,
    this.estado,
    this.rua,
    this.numero,
    this.bairro,
  });

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      id: json['id']?.toString() ?? '',
      nome: json['nome'] ?? '',
      email: json['email'],
      tipo: json['tipo'],
      cidade: json['cidade'],
      estado: json['estado'],
      rua: json['rua'],
      numero: json['numero'],
      bairro: json['bairro'],
    );
  }
}

class UserSummary {
  final int id;
  final String name;
  final String? email;

  UserSummary({
    required this.id,
    required this.name,
    this.email,
  });

  factory UserSummary.fromJson(Map<String, dynamic> json) {
    return UserSummary(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'],
    );
  }
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  try {
    return DateTime.parse(value);
  } catch (_) {
    return null;
  }
}
