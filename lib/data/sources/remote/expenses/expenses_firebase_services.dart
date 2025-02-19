import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:moneyy/data/models/expenses/user_expenses.dart';

class ExpensesFirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // GET CURRENT USER ID
  String? _getCurrentUserId() {
    final User? currentUser = _auth.currentUser;
    return currentUser?.uid;
  }



  // TO UPDATE EXPENSE
  Future<Either<String, String>> updateExpense(String uidOfTransaction, ExpensesModel updateExpense) async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Left("User is not found");
    }

    final newSpendingRef = FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("spendings")
        .doc(uidOfTransaction);

    await newSpendingRef.update({
      'spendingAmount': updateExpense.spendingAmount,
      'spendingCategory': updateExpense.spendingCategory,
      'spendingDescription': updateExpense.spendingDescription,
      'spendingDate': updateExpense.spendingDate,
      'createdAt': Timestamp.fromDate(DateTime.now()),
      'uidOfTransaction': uidOfTransaction,
    });

    return Right("Successfully updated");

  } on FirebaseException catch (e) {
    return Left("Firebase error: ${e.message}");
  } catch (e) {
    return Left("Unexpected error occurred");
  }
}


  // ADD EXPENSE
  Future<Either<String, String>> addExpense(ExpensesModel expense) async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Left("User not found");
    }

    final userDocRef = FirebaseFirestore.instance.collection("users").doc(user.uid);
    final newSpendingRef = userDocRef.collection("spendings").doc();

    // Create a local cache write immediately
    newSpendingRef.set({
      'spendingAmount': expense.spendingAmount,
      'spendingCategory': expense.spendingCategory,
      'spendingDescription': expense.spendingDescription,
      'spendingDate': expense.spendingDate,
      'createdAt':Timestamp.fromDate(DateTime.now()), // Local timestamp for offline support

      'uidOfTransaction': newSpendingRef.id,
    }, SetOptions(merge: true)); // Merge in case of offline sync issues
    return Right("Expense added (will sync when online)");
  } catch (e) {
    return Left("Error while adding: ${e.toString()}");
  }
}


 // LAST 15 DAYS EXPENSE
  Future<Map<String, double>> fetchLastSevenDayExpenses() async {
    try {
    final now = DateTime.now();
    final fifteenDaysAgo = now.subtract(const Duration(days: 15));

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      throw Exception("User is not authenticated.");
    }

    final querySnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('spendings')
        .where('spendingDate', isGreaterThanOrEqualTo: Timestamp.fromDate(fifteenDaysAgo))
        .where('spendingCategory', whereIn: ['Groceries', 'Food', 'Transport','Stationary','Entertainment'])
        .get();

    final expenses = querySnapshot.docs
        .map((doc) => ExpensesModel.fromJson(doc.data(), doc.id))
        .toList();

    Map<String, double> expensesPerDay = {};

    for (int i = 0; i <= 14; i++) {
      final day = now.subtract(Duration(days: i));
      final dayKey = _formatDayWithSuffix(day.day);
      expensesPerDay[dayKey] = 0;
    }

    for (final expense in expenses) {
      final expenseDate = expense.spendingDate;
      final dayKey = _formatDayWithSuffix(expenseDate.day);
      if (expensesPerDay.containsKey(dayKey)) {
        expensesPerDay[dayKey] = expensesPerDay[dayKey]! + expense.spendingAmount;
      }
    }

    return expensesPerDay;
  } catch (e) {
    throw Exception('Failed to fetch last 15 days expenses: $e');
  }
}

  String _formatDayWithSuffix(int day) {
  if (day >= 11 && day <= 13) {
    return '${day}th';
  }
  switch (day % 10) {
    case 1:
      return '${day}st';
    case 2:
      return '${day}nd';
    case 3:
      return '${day}rd';
    default:
      return '${day}th';
  }
  }


// FETCH ALL EXPENSES
Future<List<ExpensesModel>> fetchAllExpenses({DateTime? lastSpendingDate, required int pageSize}) async {
  try {
    final String? userId = _getCurrentUserId();
    if (userId == null) {
      throw Exception("User is not logged in");
    }

    Query query = _firestore
        .collection('users')
        .doc(userId)
        .collection('spendings')
        .orderBy('spendingDate', descending: true)
        .limit(pageSize);

    if (lastSpendingDate != null) {
      query = query.startAfter([lastSpendingDate]);
    }

    try{
    final QuerySnapshot snapshot = await query.get(GetOptions(source: Source.cache));
    final List<ExpensesModel> expenses = snapshot.docs.map((doc) {
      return ExpensesModel.fromJson(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
    }).toList();
        return expenses;
    }
    catch (e){
    final QuerySnapshot snapshot = await query.get(GetOptions(source: Source.server));
    final List<ExpensesModel> expenses = snapshot.docs.map((doc) {
      return ExpensesModel.fromJson(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
    }).toList();
    return expenses;
    }


  } catch (e) {
    return [];
  }
}


  // LAST 3 EXPENSES
  Future<List<ExpensesModel>> fetchLastThreeExpenses() async {
    try {
      final String? userId = _getCurrentUserId();

      if (userId == null) {
        throw Exception("User is not logged in");
      }

      // Fetch the last 3 documents from the 'spendings' subcollection
      Query query = _firestore
        .collection('users')
        .doc(userId)
        .collection('spendings')
        .limit(3)
        .orderBy("spendingDate", descending: true);

      try{
            final QuerySnapshot snapshot = await query.get(GetOptions(source: Source.cache));
            final List<ExpensesModel> expenses = snapshot.docs.map((doc) {
            return ExpensesModel.fromJson(
            doc.data() as Map<String, dynamic>,
            doc.id,
          );
          }).toList();
              return expenses;
            }
      catch (e){
            final QuerySnapshot snapshot = await query.get(GetOptions(source: Source.server));
            final List<ExpensesModel> expenses = snapshot.docs.map((doc) {
                  return ExpensesModel.fromJson(
                    doc.data() as Map<String, dynamic>,
                    doc.id,
                  );
                }).toList();
        return expenses;
      }
      

    } catch (e) {
      return [];
    }
  }

// DELETE THE EXPENSE
Future<Either<String, String>> deleteExpenses(String uidOfTransaction) async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Left("User is not logged in");

    final userDocRef = FirebaseFirestore.instance.collection("users").doc(user.uid);
    final spendingRef = userDocRef.collection("spendings").doc(uidOfTransaction);

    final batch = FirebaseFirestore.instance.batch();
    
    final spendingSnapshot = await spendingRef.get();
    if (!spendingSnapshot.exists) return Left("Transaction not found");

  
    batch.delete(spendingRef);

    await batch.commit();

    return Right("Successfully deleted the expense");
  } catch (e) {
    return Left("Failed to delete expense: ${e.toString()}");
  }
}


// FECTH COMPLETE EXPENSES
Future<List<ExpensesModel>> fetchCompleteExpenses() async {
  try {
    final String? userId = _getCurrentUserId();
    if (userId == null) {
      throw Exception("User is not logged in");
    }

    Query query = _firestore
        .collection('users')
        .doc(userId)
        .collection('spendings')
        .orderBy('spendingDate', descending: true);


    try{
    final QuerySnapshot snapshot = await query.get(GetOptions(source: Source.cache));
    final List<ExpensesModel> expenses = snapshot.docs.map((doc) {
      return ExpensesModel.fromJson(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
    }).toList();
        return expenses;
    }
    catch (e){
    final QuerySnapshot snapshot = await query.get(GetOptions(source: Source.server));
    final List<ExpensesModel> expenses = snapshot.docs.map((doc) {
      return ExpensesModel.fromJson(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
    }).toList();
    return expenses;
    }
  } catch (e) {
    return [];
  }
}

}