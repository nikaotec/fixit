import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import '../models/order.dart';
import 'firestore_helper.dart';

class FirestoreEquipmentService {
  static Future<CollectionReference> _collection() =>
      FirestoreHelper.companyCollection('equipment');

  static Future<Equipamento> createEquipamento({
    required String nome,
    String? serial,
    String? clienteId,
    String? localizacao,
    double? latitude,
    double? longitude,
    String? imageUrl,
  }) async {
    final col = await _collection();
    final qrCode = '${DateTime.now().millisecondsSinceEpoch}';

    final data = {
      'nome': nome,
      'codigo': serial ?? '',
      'qrCode': qrCode,
      if (localizacao != null) 'localizacao': localizacao,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (clienteId != null) 'clienteId': clienteId,
      if (imageUrl != null) 'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
    };

    final docRef = await col.add(data);
    final snap = await docRef.get();
    return Equipamento.fromMap(snap.data() as Map<String, dynamic>, snap.id);
  }

  static Future<List<Equipamento>> getAll() async {
    final col = await _collection();
    final snapshot = await col.orderBy('nome').get();
    return snapshot.docs
        .map(
          (doc) =>
              Equipamento.fromMap(doc.data() as Map<String, dynamic>, doc.id),
        )
        .toList();
  }

  static Stream<List<Equipamento>> streamAll() async* {
    final col = await _collection();
    yield* col
        .orderBy('nome')
        .snapshots()
        .map(
          (snap) => snap.docs
              .map(
                (doc) => Equipamento.fromMap(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList(),
        );
  }

  static Future<Equipamento> updateEquipamento({
    required String id,
    required String nome,
    String? serial,
    String? clienteId,
    String? localizacao,
    double? latitude,
    double? longitude,
    String? imageUrl,
  }) async {
    final col = await _collection();
    final data = {
      'nome': nome,
      'codigo': serial ?? '',
      if (localizacao != null) 'localizacao': localizacao,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (clienteId != null) 'clienteId': clienteId,
      if (imageUrl != null) 'imageUrl': imageUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await col.doc(id).update(data);
    final snap = await col.doc(id).get();
    return Equipamento.fromMap(snap.data() as Map<String, dynamic>, snap.id);
  }

  static Future<void> deleteEquipamento({required String id}) async {
    final col = await _collection();
    await col.doc(id).delete();
  }
}
