import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import '../models/order.dart';
import 'firestore_helper.dart';

class FirestoreClientService {
  static Future<CollectionReference> _collection() =>
      FirestoreHelper.companyCollection('clients');

  static Future<Cliente> create({
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
    double? latitude,
    double? longitude,
  }) async {
    final col = await _collection();

    // Check for duplicate by documento
    final existing = await col
        .where('documento', isEqualTo: documento)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      throw DuplicateClientException(
        'Cliente com este documento já cadastrado',
        existing.docs.first.id,
      );
    }

    final data = {
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
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      'ativo': true,
      'createdAt': FieldValue.serverTimestamp(),
    };

    final docRef = await col.add(data);
    final snap = await docRef.get();
    return Cliente.fromMap(snap.data() as Map<String, dynamic>, snap.id);
  }

  static Future<List<Cliente>> getAll({
    bool? apenasAtivos,
    String? nome,
    String? tipo,
  }) async {
    final col = await _collection();
    Query query = col;

    if (apenasAtivos == true) {
      query = query.where('ativo', isEqualTo: true);
    }
    if (tipo != null && tipo.isNotEmpty) {
      query = query.where('tipo', isEqualTo: tipo);
    }

    final snapshot = await query.get();
    var clientes = snapshot.docs
        .map(
          (doc) => Cliente.fromMap(doc.data() as Map<String, dynamic>, doc.id),
        )
        .toList();

    if (nome != null && nome.isNotEmpty) {
      final lower = nome.toLowerCase();
      clientes = clientes
          .where((c) => c.nome.toLowerCase().contains(lower))
          .toList();
    }

    return clientes;
  }

  static Stream<List<Cliente>> streamAll({bool? apenasAtivos}) async* {
    final col = await _collection();
    Query query = col;
    if (apenasAtivos == true) {
      query = query.where('ativo', isEqualTo: true);
    }

    yield* query.snapshots().map(
      (snap) => snap.docs
          .map(
            (doc) =>
                Cliente.fromMap(doc.data() as Map<String, dynamic>, doc.id),
          )
          .toList(),
    );
  }

  static Future<Cliente> getById({required String id}) async {
    final col = await _collection();
    final doc = await col.doc(id).get();
    if (!doc.exists) throw Exception('Cliente não encontrado');
    return Cliente.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  static Future<Cliente> update({
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
    double? latitude,
    double? longitude,
  }) async {
    final col = await _collection();
    final data = {
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
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await col.doc(id).update(data);
    return getById(id: id);
  }

  static Future<void> deactivate({required String id}) async {
    final col = await _collection();
    await col.doc(id).update({
      'ativo': false,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> delete({required String id}) async {
    final col = await _collection();
    await col.doc(id).delete();
  }
}

class DuplicateClientException implements Exception {
  final String message;
  final String? conflictId;

  DuplicateClientException(this.message, this.conflictId);

  @override
  String toString() => message;
}
