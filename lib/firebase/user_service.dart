import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../firebase/firebase_utils.dart' as firebaseUtils;

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Fetch user data including spending details
  Future<Map<String, dynamic>> fetchUserData(context) async {
    User? user = _auth.currentUser;
    if (user == null) {
      throw Exception('No user logged in');
    }

    String userId = user.uid;
    DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
    double todayTotalSpending = await firebaseUtils.getTodayTotalSpending(context, userId);
    List<firebaseUtils.CustomTransaction> transactions = await firebaseUtils.getLastThreeTransactions(context, userId);

    if (!userDoc.exists) {
      throw Exception('User document does not exist');
    }

    return {
      'userId': userId,
      'userName': userDoc['firstName'],
      'totalSpending': (userDoc['totalSpending'] as num?)?.toDouble() ?? 0.0,
      'monthlyLimit': (userDoc['monthlyLimit'] as num?)?.toDouble() ?? 0.0,
      'dailyLimit': (userDoc['dailyLimit'] as num?)?.toDouble() ?? 0.0,
      'todaySpending': todayTotalSpending,
      'recentTransactions': transactions,
    };
  }

  // Update email for the current user
  Future<void> updateEmail(String newEmail) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }
      await user.verifyBeforeUpdateEmail(newEmail);
    } catch (e) {
      rethrow; // Rethrow the error for handling in UI
    }
  }

  // Update monthly limit for the current user
  Future<void> updateMonthlyLimit(String userId, double newLimit) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'monthlyLimit': newLimit,
      });
    } catch (e) {
      rethrow; // Rethrow the error for handling in UI
    }
  }

  // Update daily limit for the current user
  Future<void> updateDailyLimit(String userId, double newLimit) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'dailyLimit': newLimit,
      });
    } catch (e) {
      rethrow; // Rethrow the error for handling in UI
    }
  }

  // Delete the current user account
  Future<void> deleteAccount(String userId) async {
    try {
      // Show account deletion confirmation dialog here
      // Example: showAccountDeletionConfirmationDialog(context);
    } catch (e) {
      rethrow; // Rethrow the error for handling in UI
    }
  }
}
