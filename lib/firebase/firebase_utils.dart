import 'package:cloud_firestore/cloud_firestore.dart';

// Single instance of FirebaseFirestore throughout the file
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

// Constants for collection names to avoid typos and ease maintenance
const String _usersCollection = 'users';
const String _spendingsCollection = 'spendings';
const String _incomeCollection = "income";

// TO GET MONTHLY TOTAL INCOME
Future<double> getMonthTotalIncome(String userId) async {
  try {
    double thisMonthIncome = 0.0;
    DateTime now = DateTime.now();
    DateTime startOfMonth = DateTime(now.year, now.month, 1); // 1st of the current month at 12:00 AM
    DateTime currentTime = now; // Current date and time

    QuerySnapshot spendingSnapshot = await _firestore
        .collection(_usersCollection)
        .doc(userId)
        .collection(_incomeCollection)
        .where('incomeDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .where('incomeDate', isLessThanOrEqualTo: Timestamp.fromDate(currentTime))
        .get();

    for (var doc in spendingSnapshot.docs) {
      thisMonthIncome += (doc['incomeAmount'] as num).toDouble();
    }
    return thisMonthIncome;
  } catch (e) {
    throw Exception('Error in getMonthTotalIncome: $e');
  }
}

// Function to get the this month expense so far
Future<double> getMonthTotalSpending(String userId) async {
  try {
    double thisMonthSpending = 0.0;
    DateTime now = DateTime.now();
    DateTime startOfMonth = DateTime(now.year, now.month, 1); // 1st of the current month at 12:00 AM
    DateTime currentTime = now; // Current date and time

    QuerySnapshot spendingSnapshot = await _firestore
        .collection(_usersCollection)
        .doc(userId)
        .collection(_spendingsCollection)
        .where('spendingDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .where('spendingDate', isLessThanOrEqualTo: Timestamp.fromDate(currentTime))
        .get();

    for (var doc in spendingSnapshot.docs) {
      thisMonthSpending += (doc['spendingAmount'] as num).toDouble();
    }
    return thisMonthSpending;
  } catch (e) {
    throw Exception('Error in getMonthTotalSpending: $e');
  }
}

// Function to get the today's expense so far
Future<double> getTodayTotalSpending(String userId) async {
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
    throw Exception('Error in getTodayTotalSpending: $e');
  }
}

// Function to get the today's income so far
Future<double> getTodayTotalIncome(String userId) async {
  try {
    double totalIncome = 0.0;
    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day);
    DateTime endOfDay = startOfDay.add(Duration(days: 1)).subtract(Duration(seconds: 1));

    QuerySnapshot spendingSnapshot = await _firestore
        .collection(_usersCollection)
        .doc(userId)
        .collection(_incomeCollection)
        .where('incomeDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('incomeDate', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .get();

    for (var doc in spendingSnapshot.docs) {
      totalIncome += (doc['incomeAmount'] as num).toDouble();
    }
    return totalIncome;
  } catch (e) {
    throw Exception('Error in getTodayTotalIncome: $e');
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
Future<List<CustomTransaction>> getLastThreeTransactions(String userId) async {
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
    throw Exception('Error in getLastThreeTransactions: $e');
  }
}

// Function to get all the spendings list
Future<List<CustomTransaction>> getAllSpendings(String userId) async {
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
    throw Exception('Error in getAllSpendings: $e');
  }
}

// Function to delete a transaction
Future<void> deleteTransaction(String userId, String transactionId) async {
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
    throw Exception('Error in deleteTransaction: $e');
  }
}

// Function to update a transaction
Future<void> updateTransaction(String userId, String transactionId, Map<String, dynamic> updatedData) async {
  try {
    await _firestore
        .collection(_usersCollection)
        .doc(userId)
        .collection(_spendingsCollection)
        .doc(transactionId)
        .update(updatedData);
  } catch (e) {
    throw Exception('Error in updateTransaction: $e');
  }
}