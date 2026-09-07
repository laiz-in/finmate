import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_profile.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<void> setProfile(UserProfile profile) async {
    print("came in profile services");

    await _firestore.collection('users').doc(profile.uid).set(
          profile.toMap(),
          SetOptions(merge: true),
        );
  }

  Future<UserProfile?> getProfile(String uid) async {
    print("came in getProfile");
    final doc = await _firestore
        .collection('users')
        .doc(uid)
        .get()
        .timeout(const Duration(seconds: 8));
    if (!doc.exists) return null;
    final data = doc.data();
    if (data == null) return null;
    print("just before returning profile data in profile service");
    return UserProfile.fromMap(data);
  }
}