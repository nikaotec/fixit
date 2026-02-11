import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:firebase_auth/firebase_auth.dart';

/// Helper to get the current user's company path in Firestore.
class FirestoreHelper {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static String get uid {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');
    return user.uid;
  }

  /// Fetches the companyId for the current user from Firestore.
  static Future<String> getCompanyId() async {
    final doc = await _firestore.collection('users').doc(uid).get();
    final data = doc.data();
    if (data == null || data['companyId'] == null) {
      throw Exception('Company not found for user');
    }
    return data['companyId'] as String;
  }

  /// Returns a reference to the company document.
  static Future<DocumentReference> companyRef() async {
    final companyId = await getCompanyId();
    return _firestore.collection('companies').doc(companyId);
  }

  /// Returns a reference to a sub-collection under the company.
  static Future<CollectionReference> companyCollection(String name) async {
    final ref = await companyRef();
    return ref.collection(name);
  }
}
