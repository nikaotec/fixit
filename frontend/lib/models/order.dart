import 'package:cloud_firestore/cloud_firestore.dart' hide Order;

class Order {
  final String id;
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

  factory Order.fromMap(Map<String, dynamic> map, String docId) {
    return Order(
      id: docId,
      status: map['status'] ?? 'ABERTA',
      priority: map['prioridade'] ?? map['priority'] ?? 'MEDIA',
      orderType: map['tipo'] ?? map['orderType'] ?? 'MANUTENCAO',
      problemDescription: map['problemDescription'],
      equipmentBrand: map['equipmentBrand'],
      equipmentModel: map['equipmentModel'],
      equipamento: Equipamento.fromMap(
        map['equipamento'] ?? {},
        map['equipamentoId'] ?? '',
      ),
      checklist: Checklist.fromMap(
        map['checklist'] ?? {},
        map['checklistId'] ?? '',
      ),
      cliente: map['cliente'] != null
          ? Cliente.fromMap(map['cliente'], map['clienteId'] ?? '')
          : null,
      criador: map['criador'] != null
          ? UserSummary.fromMap(map['criador'])
          : null,
      responsavel: map['responsavel'] != null
          ? UserSummary.fromMap(map['responsavel'])
          : null,
      dataPrevista: _parseTimestamp(map['dataPrevista']),
      dataCriacao: _parseTimestamp(map['dataCriacao']),
      dataFinalizacao: _parseTimestamp(map['dataFinalizacao']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'status': status,
      'prioridade': priority,
      'tipo': orderType,
      if (problemDescription != null) 'problemDescription': problemDescription,
      if (equipmentBrand != null) 'equipmentBrand': equipmentBrand,
      if (equipmentModel != null) 'equipmentModel': equipmentModel,
      'equipamento': equipamento.toMap(),
      'equipamentoId': equipamento.id,
      'checklist': checklist.toMap(),
      'checklistId': checklist.id,
      if (cliente != null) 'cliente': cliente!.toMap(),
      if (cliente != null) 'clienteId': cliente!.id,
      if (criador != null) 'criador': criador!.toMap(),
      if (responsavel != null) 'responsavel': responsavel!.toMap(),
      if (dataPrevista != null)
        'dataPrevista': Timestamp.fromDate(dataPrevista!),
      'dataCriacao': dataCriacao != null
          ? Timestamp.fromDate(dataCriacao!)
          : FieldValue.serverTimestamp(),
      if (dataFinalizacao != null)
        'dataFinalizacao': Timestamp.fromDate(dataFinalizacao!),
    };
  }
}

class Equipamento {
  final String id;
  final String nome;
  final String codigo;
  final String qrCode;
  final String? localizacao;
  final double? latitude;
  final double? longitude;
  final String? imageUrl;
  final Cliente? cliente;

  Equipamento({
    required this.id,
    required this.nome,
    required this.codigo,
    required this.qrCode,
    this.localizacao,
    this.latitude,
    this.longitude,
    this.imageUrl,
    this.cliente,
  });

  factory Equipamento.fromMap(Map<String, dynamic> map, String docId) {
    return Equipamento(
      id: docId.isNotEmpty ? docId : (map['id']?.toString() ?? ''),
      nome: map['nome'] ?? '',
      codigo: map['codigo'] ?? '',
      qrCode: map['qrCode'] ?? '',
      localizacao: map['localizacao'],
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      imageUrl: map['imageUrl'],
      cliente: map['cliente'] != null
          ? Cliente.fromMap(map['cliente'], map['clienteId'] ?? '')
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'codigo': codigo,
      'qrCode': qrCode,
      if (localizacao != null) 'localizacao': localizacao,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (cliente != null) 'cliente': cliente!.toMap(),
      if (cliente != null) 'clienteId': cliente!.id,
    };
  }
}

class Checklist {
  final String id;
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

  factory Checklist.fromMap(Map<String, dynamic> map, String docId) {
    final list = (map['itens'] ?? []) as List;
    return Checklist(
      id: docId.isNotEmpty ? docId : (map['id']?.toString() ?? ''),
      nome: map['nome'] ?? '',
      itens: list
          .map((i) => ChecklistItem.fromMap(i as Map<String, dynamic>))
          .toList(),
      descricao: map['descricao'],
      versao: map['versao'],
      ativo: map['ativo'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'itens': itens.map((i) => i.toMap()).toList(),
      if (descricao != null) 'descricao': descricao,
      if (versao != null) 'versao': versao,
      'ativo': ativo ?? true,
    };
  }
}

class ChecklistItem {
  final String id;
  final String descricao;
  final bool obrigatorioFoto;
  final bool critico;

  ChecklistItem({
    required this.id,
    required this.descricao,
    required this.obrigatorioFoto,
    required this.critico,
  });

  factory ChecklistItem.fromMap(Map<String, dynamic> map) {
    return ChecklistItem(
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

class Cliente {
  final String id;
  final String nome;
  final String? email;
  final String? tipo;
  final String? documento;
  final String? telefone;
  final String? cidade;
  final String? estado;
  final String? rua;
  final String? numero;
  final String? bairro;
  final String? cep;
  final String? complemento;
  final String? nomeContato;
  final String? cargoContato;
  final String? notasInternas;
  final double? latitude;
  final double? longitude;
  final bool ativo;

  Cliente({
    required this.id,
    required this.nome,
    this.email,
    this.tipo,
    this.documento,
    this.telefone,
    this.cidade,
    this.estado,
    this.rua,
    this.numero,
    this.bairro,
    this.cep,
    this.complemento,
    this.nomeContato,
    this.cargoContato,
    this.notasInternas,
    this.latitude,
    this.longitude,
    this.ativo = true,
  });

  factory Cliente.fromMap(Map<String, dynamic> map, String docId) {
    return Cliente(
      id: docId.isNotEmpty ? docId : (map['id']?.toString() ?? ''),
      nome: map['nome'] ?? '',
      email: map['email'],
      tipo: map['tipo'],
      documento: map['documento'],
      telefone: map['telefone'],
      cidade: map['cidade'],
      estado: map['estado'],
      rua: map['rua'],
      numero: map['numero'],
      bairro: map['bairro'],
      cep: map['cep'],
      complemento: map['complemento'],
      nomeContato: map['nomeContato'],
      cargoContato: map['cargoContato'],
      notasInternas: map['notasInternas'],
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      ativo: map['ativo'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      if (email != null) 'email': email,
      if (tipo != null) 'tipo': tipo,
      if (documento != null) 'documento': documento,
      if (telefone != null) 'telefone': telefone,
      if (cidade != null) 'cidade': cidade,
      if (estado != null) 'estado': estado,
      if (rua != null) 'rua': rua,
      if (numero != null) 'numero': numero,
      if (bairro != null) 'bairro': bairro,
      if (cep != null) 'cep': cep,
      if (complemento != null) 'complemento': complemento,
      if (nomeContato != null) 'nomeContato': nomeContato,
      if (cargoContato != null) 'cargoContato': cargoContato,
      if (notasInternas != null) 'notasInternas': notasInternas,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      'ativo': ativo,
    };
  }
}

class UserSummary {
  final String id;
  final String name;
  final String? email;

  UserSummary({required this.id, required this.name, this.email});

  factory UserSummary.fromMap(Map<String, dynamic> map) {
    return UserSummary(
      id: map['id']?.toString() ?? '',
      name: map['name'] ?? '',
      email: map['email'],
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, if (email != null) 'email': email};
  }
}

DateTime? _parseTimestamp(dynamic value) {
  if (value == null) return null;
  if (value is Timestamp) return value.toDate();
  if (value is String) {
    try {
      return DateTime.parse(value);
    } catch (_) {
      return null;
    }
  }
  return null;
}
