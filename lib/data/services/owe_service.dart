import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/owe.dart';

class OweService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference _ref(String uid) {
    return _firestore.collection('users').doc(uid).collection('owes');
  }

  Future<void> setOwe(Owe owe) async {
    await _ref(owe.uid).doc(owe.id).set(owe.toMap());
  }

  Future<void> deleteOwe(String uid, String id) async {
    await _ref(uid).doc(id).delete();
  }

  Future<List<Owe>> fetchAll(String uid) async {
    final snapshot = await _ref(uid).get().timeout(const Duration(seconds: 8));
    return snapshot.docs.map((doc) => Owe.fromMap(doc.data() as Map<String, dynamic>)).toList();
  }
}