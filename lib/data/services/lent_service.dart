import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/lent.dart';

class LentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference _ref(String uid) {
    return _firestore.collection('users').doc(uid).collection('lents');
  }

  Future<void> setLent(Lent lent) async {
    await _ref(lent.uid).doc(lent.id).set(lent.toMap());
  }

  Future<void> deleteLent(String uid, String id) async {
    await _ref(uid).doc(id).delete();
  }

  Future<List<Lent>> fetchAll(String uid) async {
    final snapshot = await _ref(uid).get().timeout(const Duration(seconds: 8));
    return snapshot.docs.map((doc) => Lent.fromMap(doc.data() as Map<String, dynamic>)).toList();
  }
}