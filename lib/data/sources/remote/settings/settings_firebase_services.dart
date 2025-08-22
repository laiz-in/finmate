
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class SettingsFirebaseService {
  Future<Either> resetName({required String firstName, required String lastName});


  Future<Either> resetDailyLimit({required int dailyLimit});

  Future<Either> resetMonthlyLimit({required int monthlyLimit});

  Future<Either> sendFeedback({required String feedback});



}




class SettingsFirebaseServiceImpl extends SettingsFirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;


// DAILY LIMIT RESET SERVICE
@override
Future<Either> resetDailyLimit({required int dailyLimit}) async {
  try {
    User? user = _auth.currentUser;
    if (user == null) return Left("User not logged in");

    if (dailyLimit > 999999) return Left("Maximum daily limit is 999999");

    FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'dailyLimit': dailyLimit,
    });
    
    return Right("Success");

  } catch (e) {
    return Left("Could not update daily limit!");
  }
}



// MONTHLY LIMIT RESET SERVICE
@override
Future<Either<String, String>> resetMonthlyLimit({required int monthlyLimit}) async {
  try {
    User? user = _auth.currentUser;
    if (user == null) {
      return Left("User not logged in");
    }
    if (monthlyLimit > 999999) {
      return Left("Maximum monthly limit is 999999");
    }
        FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'monthlyLimit': monthlyLimit,
    });
    return Right("Monthly limit updated successfully");
  } on FirebaseException catch (e) {
    return Left("Failed to update monthly limit in Firestore: ${e.message}");
  } catch (e) {
    return Left("An unexpected error occurred: $e");
  }
}


// FEEDBACK SERVICE
@override
Future<Either> sendFeedback({required String feedback}) async {
  try {
    User? user = _auth.currentUser;

    String docId = FirebaseFirestore.instance.collection('feedbacks').doc().id;
    // Add feedback using set() with merge: true (ensures local write)
    FirebaseFirestore.instance.collection('feedbacks').doc(docId).set({
      'uid': user?.uid,
      'addedDate': DateTime.now(),
      'feedBackText': feedback,
      'addedUser': user?.email,
    }, SetOptions(merge: true)); // Ensures it syncs later

    return Right("success");

  } catch (e) {
    return Left("could not add the feedback!");
  }
}


// RESET NAME SERVICE
@override
Future<Either<String, String>> resetName({
  required String firstName,
  required String lastName,
}) async {
  try {
    // GET THE USER ID
    User? user = _auth.currentUser;
    if (user == null) return Left("User not found");

    // UPDATE THE USER DATA IN FIRESTORE (Works Offline)
    FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'firstName': firstName,
      'lastName': lastName,
    });
    return Right("Success");
  } on FirebaseException catch (e) {
    return Left("Firestore error: ${e.message}");
  } catch (e) {
    return Left("Could not edit the name!");
  }
}



}
