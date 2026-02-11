import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import '../models/order.dart';
import 'firestore_helper.dart';

class FirestoreOrderService {
  static Future<CollectionReference> _collection() =>
      FirestoreHelper.companyCollection('serviceOrders');

  static Future<List<Order>> getAll() async {
    final col = await _collection();
    final snapshot = await col.orderBy('dataCriacao', descending: true).get();
    return snapshot.docs
        .map((doc) => Order.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  static Stream<List<Order>> streamAll() async* {
    final col = await _collection();
    yield* col
        .orderBy('dataCriacao', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map(
                (doc) =>
                    Order.fromMap(doc.data() as Map<String, dynamic>, doc.id),
              )
              .toList(),
        );
  }

  static Stream<Order?> streamById(String id) async* {
    final col = await _collection();
    yield* col.doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      return Order.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    });
  }

  static Future<Order> create({
    String? equipamentoId,
    String? checklistId,
    String? clienteId,
    String? responsavelId,
    required String prioridade,
    required String orderType,
    String? problemDescription,
    String? equipmentBrand,
    String? equipmentModel,
    DateTime? dataPrevista,
    Map<String, dynamic>? equipamentoData,
    Map<String, dynamic>? checklistData,
    Map<String, dynamic>? clienteData,
    Map<String, dynamic>? responsavelData,
  }) async {
    final col = await _collection();

    final data = <String, dynamic>{
      'status': 'ABERTA',
      'prioridade': prioridade,
      'tipo': orderType,
      if (problemDescription != null && problemDescription.trim().isNotEmpty)
        'problemDescription': problemDescription.trim(),
      if (equipmentBrand != null && equipmentBrand.trim().isNotEmpty)
        'equipmentBrand': equipmentBrand.trim(),
      if (equipmentModel != null && equipmentModel.trim().isNotEmpty)
        'equipmentModel': equipmentModel.trim(),
      if (equipamentoId != null) 'equipamentoId': equipamentoId,
      if (equipamentoData != null) 'equipamento': equipamentoData,
      if (checklistId != null) 'checklistId': checklistId,
      if (checklistData != null) 'checklist': checklistData,
      if (clienteId != null) 'clienteId': clienteId,
      if (clienteData != null) 'cliente': clienteData,
      if (responsavelId != null) 'responsavelId': responsavelId,
      if (responsavelData != null) 'responsavel': responsavelData,
      if (dataPrevista != null)
        'dataPrevista': Timestamp.fromDate(dataPrevista),
      'dataCriacao': FieldValue.serverTimestamp(),
      'criador': {'id': FirestoreHelper.uid},
    };

    final docRef = await col.add(data);
    final snap = await docRef.get();
    return Order.fromMap(snap.data() as Map<String, dynamic>, snap.id);
  }

  static Future<Order> getById({required String id}) async {
    final col = await _collection();
    final doc = await col.doc(id).get();
    if (!doc.exists) throw Exception('Ordem não encontrada');
    return Order.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  static Future<void> updateStatus({
    required String id,
    required String status,
  }) async {
    final col = await _collection();
    await col.doc(id).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> assignTechnician({
    required String orderId,
    required String technicianId,
    required String technicianName,
  }) async {
    final col = await _collection();
    await col.doc(orderId).update({
      'responsavel': {'id': technicianId, 'name': technicianName},
      'responsavelId': technicianId,
      'status': 'ATRIBUIDA',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
