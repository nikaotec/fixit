import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import '../models/order.dart';
import 'firestore_helper.dart';

class FirestoreChecklistService {
  static Future<CollectionReference> _collection() =>
      FirestoreHelper.companyCollection('checklists');

  static Future<List<Checklist>> getAll() async {
    final col = await _collection();
    final snapshot = await col.orderBy('nome').get();
    return snapshot.docs
        .map(
          (doc) =>
              Checklist.fromMap(doc.data() as Map<String, dynamic>, doc.id),
        )
        .toList();
  }

  static Stream<List<Checklist>> streamAll() async* {
    final col = await _collection();
    yield* col
        .orderBy('nome')
        .snapshots()
        .map(
          (snap) => snap.docs
              .map(
                (doc) => Checklist.fromMap(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList(),
        );
  }

  static Future<Checklist> create({
    required String nome,
    String? descricao,
    required List<Map<String, dynamic>> itens,
  }) async {
    final col = await _collection();
    final data = {
      'nome': nome,
      if (descricao != null) 'descricao': descricao,
      'itens': itens,
      'ativo': true,
      'versao': 1,
      'createdAt': FieldValue.serverTimestamp(),
    };

    final docRef = await col.add(data);
    final snap = await docRef.get();
    return Checklist.fromMap(snap.data() as Map<String, dynamic>, snap.id);
  }

  static Future<Checklist> update({
    required String id,
    required String nome,
    String? descricao,
    required List<Map<String, dynamic>> itens,
  }) async {
    final col = await _collection();
    await col.doc(id).update({
      'nome': nome,
      if (descricao != null) 'descricao': descricao,
      'itens': itens,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    final snap = await col.doc(id).get();
    return Checklist.fromMap(snap.data() as Map<String, dynamic>, snap.id);
  }

  static Future<void> delete({required String id}) async {
    final col = await _collection();
    await col.doc(id).delete();
  }
}
