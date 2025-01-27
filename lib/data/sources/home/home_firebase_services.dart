

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:moneyy/domain/entities/auth/user.dart';

class FirebaseHomeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Either<String, UserEntity>> fetchCurrentUserData() async {
    try {
      String uid = _auth.currentUser!.uid;
      DocumentSnapshot userDoc = await _firestore.collection("users").doc(uid).get();

      if (userDoc.exists) {
        UserEntity user = UserEntity.fromJson(userDoc.data() as Map<String, dynamic>);
        return Right(user);
      } else {
        return Left("User data not found");
      }
    } catch (e) {
      return Left("Error fetching user data in services: $e");
    }
  }
}
