
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';



abstract class SettingsFirebaseService {


  Future<Either> resetDailyLimit({required int dailyLimit});

  Future<Either> resetMonthlyLimit({required int monthlyLimit});

  Future<Either> sendFeedback({required String feedback});


}




class SettingsFirebaseServiceImpl extends SettingsFirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;


// Firebase service for daily limit reset
  @override
  Future<Either> resetDailyLimit({required int dailyLimit}) async {
    try {
      // Get the current user
      User? user = _auth.currentUser;

      if (user == null) {
        return Left("User not logged in");
      }
      if(dailyLimit >9999){
        return Left("maximum daily limit is 9999");

      }
      // Update the daily limit in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'dailyLimit': dailyLimit});

      return Right("Daily limit updated successfully");
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        return Left("Invalid email address");
      } else {
        return Left("Could not update the daily limit due to FirebaseAuthException");
      }
    } on FirebaseException catch (e) {
      return Left("Failed to update daily limit: ${e.message}");
    } catch (e) {
      return Left("Unexpected error occurred: $e");
    }
  }


// Firebase service for monthly limit reset
  @override
  Future<Either> resetMonthlyLimit({required int monthlyLimit}) async {
    try {
      // Get the current user
      User? user = _auth.currentUser;

      if (user == null) {
        return Left("User not logged in");
      }
      if(monthlyLimit >999999){
        return Left("maximum monthly limit is 999999");

      }
      // Update the daily limit in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'monthlyLimit': monthlyLimit});

      return Right("Daily limit updated successfully");
    } on FirebaseException catch (e) {
      return Left("Failed to update daily limit due to firebase exception: :$e");
    } catch (e) {
      return Left("Unexpected error occurred: $e");
    }
  }


// Firebase service for feedback
  @override
  Future<Either> sendFeedback({required String feedback}) async {
  try {

    // Get the current user
    User? user = _auth.currentUser;
    await FirebaseFirestore.instance.collection('feedbacks').add({
            'uid': user?.uid,
            'addedDate': DateTime.now(),
            'feedBackText': feedback,
            'addedUser': user?.email,
          });
    return Right("success");

  } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        return Left("firebase exception");
      }
      else{
        return Left("could not add the feedback!");
      }
    }
}

}
