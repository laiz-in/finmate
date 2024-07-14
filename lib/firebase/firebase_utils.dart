// C:\Users\Hp\Desktop\moneyy\moneyy\lib\firebase\firebase_utils.dart

import 'package:cloud_firestore/cloud_firestore.dart';

import '../ui/error_snackbar.dart';

//single instance of FirebaseFirestore throughout the file
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

// Constants for collection names to avoid typos and ease maintenance
const String _usersCollection = 'users';
const String _spendingsCollection = 'spendings';

// Function to get the today's expense so far
Future<double> getTodayTotalSpending(context,String userId) async {
  try {
    double totalSpending = 0.0;
    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day);
    DateTime endOfDay = startOfDay.add(Duration(days: 1)).subtract(Duration(seconds: 1));

    QuerySnapshot spendingSnapshot = await _firestore
        .collection(_usersCollection)
        .doc(userId)
        .collection(_spendingsCollection)
        .where('spendingDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('spendingDate', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .get();

    for (var doc in spendingSnapshot.docs) {
      totalSpending += (doc['spendingAmount'] as num).toDouble();
    }
    
    return totalSpending;
  } catch (e) {
    errorSnackbar(context,'Error in getTodayTotalSpending: $e');
    rethrow;
  }
}

class CustomTransaction {
  final DateTime date;
  final double spendingAmount;
  final String spendingCategory;
  final String spendingDescription;
  final String uid;

  CustomTransaction({
    required this.date,
    required this.spendingAmount,
    required this.spendingCategory,
    required this.spendingDescription,
    required this.uid,
  });

  factory CustomTransaction.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return CustomTransaction(
      date: (data['spendingDate'] as Timestamp).toDate(),
      spendingAmount: (data['spendingAmount'] as num).toDouble(),
      spendingCategory: data['spendingCategory'] as String,
      spendingDescription: data['spendingDescription'] as String,
      uid: doc.id,
    );
  }
}

// Function to get the last three spendings
Future<List<CustomTransaction>> getLastThreeTransactions(context,String userId) async {
  try {
    QuerySnapshot spendingSnapshot = await _firestore
        .collection(_usersCollection)
        .doc(userId)
        .collection(_spendingsCollection)
        .orderBy('spendingDate', descending: true)
        .limit(3)
        .get();

    return spendingSnapshot.docs.map((doc) => CustomTransaction.fromFirestore(doc)).toList();
  } catch (e) {
    errorSnackbar(context,'Error in getLastThreeTransactions: $e');
    rethrow;
  }
}

// Function to get all the spendings list
Future<List<CustomTransaction>> getAllSpendings(context,String userId) async {
  try {
    // Implement pagination for better performance with large datasets
    const int pageSize = 20;
    QuerySnapshot spendingSnapshot = await _firestore
        .collection(_usersCollection)
        .doc(userId)
        .collection(_spendingsCollection)
        .orderBy('spendingDate', descending: true)
        .limit(pageSize)
        .get();

    return spendingSnapshot.docs.map((doc) => CustomTransaction.fromFirestore(doc)).toList();
  } catch (e) {
    errorSnackbar(context,'Error in getAllSpendings: $e');
    rethrow;
  }
}

// Function to delete a transaction
Future<void> deleteTransaction(context,String userId, String transactionId) async {
  try {
    return await _firestore.runTransaction((transaction) async {
      DocumentReference userRef = _firestore.collection(_usersCollection).doc(userId);
      DocumentReference transactionRef = userRef.collection(_spendingsCollection).doc(transactionId);

      DocumentSnapshot transactionDoc = await transaction.get(transactionRef);
      if (!transactionDoc.exists) {
        throw Exception('Transaction not found');
      }

      double spendingAmount = (transactionDoc['spendingAmount'] as num).toDouble();

      DocumentSnapshot userDoc = await transaction.get(userRef);
      if (!userDoc.exists) {
        throw Exception('User not found');
      }

      double currentTotalSpending = (userDoc['totalSpending'] as num).toDouble();
      double newTotalSpending = currentTotalSpending - spendingAmount;

      transaction.delete(transactionRef);
      transaction.update(userRef, {'totalSpending': newTotalSpending});
    });
  } catch (e) {
    errorSnackbar(context,'Error in deleteTransaction: $e');
    rethrow;
  }
}

// Function to update a transaction
Future<void> updateTransaction(context,String userId, String transactionId, Map<String, dynamic> updatedData) async {
  try {
    await _firestore
        .collection(_usersCollection)
        .doc(userId)
        .collection(_spendingsCollection)
        .doc(transactionId)
        .update(updatedData);
  } catch (e) {
    errorSnackbar(context,'Error in updateTransaction: $e');
    rethrow;
  }
}