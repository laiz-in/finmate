import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:moneyy/data/models/expenses/user_expenses.dart';

class ExpensesFirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Fetch current logged-in user's ID
  String? _getCurrentUserId() {
    final User? currentUser = _auth.currentUser;
    return currentUser?.uid;
  }

  // ADD EXPENSE
  Future<void> addExpense(ExpensesModel expense) async {
    try {
      final String? userId = _getCurrentUserId();

      if (userId == null) {
        throw Exception("User is not logged in");
      }
      print("===================================================");
      print(expense.createdAt);
      print(expense.uidOfTransaction);
      print(expense.spendingAmount);
      print(expense.spendingCategory);
      print(expense.spendingDescription);
      print(expense.spendingDate);




    print("===================================================");

      // Adding the expense to Firestore
      await _firestore
          .collection('users')
          .doc(userId) // The current user's ID
          .collection('spendings')
          .doc(expense.uidOfTransaction) // Use uidOfTransaction as the document ID for the expense
          .set(expense.toJson());


    } catch (e) {
      throw Exception("Failed to add expense: $e");
    }
  }

 // LAST 7 DAYS EXPENSE
  Future<Map<String, double>> fetchLastSevenDayExpenses() async {
    try {
    final now = DateTime.now();
    final fifteenDaysAgo = now.subtract(const Duration(days: 14)); // 15 days back

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      throw Exception("User is not authenticated.");
    }

    // Query expenses for the last 15 days, filtering by category
    final querySnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('spendings')
        .where('spendingDate', isGreaterThanOrEqualTo: Timestamp.fromDate(fifteenDaysAgo))
        .where('spendingCategory', whereIn: ['Groceries', 'Food', 'Transport']) // Filter by category
        .get();

    final expenses = querySnapshot.docs
        .map((doc) => ExpensesModel.fromJson(doc.data(), doc.id))
        .toList();

    // Initialize a map to store summed expenses per date (key formatted as "9th", "8th", etc.)
    Map<String, double> expensesPerDay = {};

    // Iterate through the last 15 days
    for (int i = 0; i <= 14; i++) {
      final day = now.subtract(Duration(days: i));
      final dayKey = _formatDayWithSuffix(day.day); // Format the day (e.g., "9th", "8th")
      expensesPerDay[dayKey] = 0; // Initialize each day with 0
    }

    // Sum the expenses per day
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
  Future<List<ExpensesModel>> fetchAllExpenses() async {
    try {
      final String? userId = _getCurrentUserId();

      if (userId == null) {
        throw Exception("User is not logged in");
      }

      // Fetch all documents from the 'spendings' subcollection
      final QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('spendings')
          .orderBy('spendingDate', descending: true) // Optional: sort by date
          .get();

      // Map documents to ExpensesModel
      final List<ExpensesModel> expenses = snapshot.docs.map((doc) {
        return ExpensesModel.fromJson(
          doc.data() as Map<String, dynamic>, 
          doc.id, // Use the document ID as uidOfTransaction
        );
      }).toList();

      return expenses;
    } catch (e) {
      throw Exception("Failed to fetch expenses: $e");
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
      final QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('spendings')
          .orderBy('spendingDate', descending: true)
          .limit(3)
          .get();

      // Map documents to ExpensesModel
      final List<ExpensesModel> expenses = snapshot.docs.map((doc) {
        return ExpensesModel.fromJson(
          doc.data() as Map<String, dynamic>,
          doc.id, // Use the document ID as uidOfTransaction
        );
      }).toList();

      return expenses;
    } catch (e) {
      throw Exception("Failed to fetch last three expenses: $e");
    }
  }
}
