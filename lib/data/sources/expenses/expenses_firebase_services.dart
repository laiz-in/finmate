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
      final sevenDaysAgo = now.subtract(const Duration(days: 6));

      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception("User is not authenticated.");
      }

      // Query expenses for the last 7 days
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('spendings')
          .where('spendingDate', isGreaterThanOrEqualTo: Timestamp.fromDate(sevenDaysAgo))
          .get();

      final expenses = querySnapshot.docs
          .map((doc) => ExpensesModel.fromJson(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      // Initialize a map to store summed expenses per day of the week
      Map<String, double> expensesPerDay = {
        'mon': 0,
        'sun': 0,
        'sat': 0,
        'fri': 0,
        'thu': 0,
        'wed': 0,
        'tue': 0,
      };

      for (final expense in expenses) {
        final weekday = expense.spendingDate.weekday;
        final key = _getDayKey(weekday); // Map day number to string (mon, tue, etc.)
        expensesPerDay[key] = expensesPerDay[key]! + expense.spendingAmount;
      }

      return expensesPerDay;
    } catch (e) {
      throw Exception('Failed to fetch last 7 day expenses: $e');
    }
  }

  // Helper method to map weekday number to a string key
  String _getDayKey(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'mon';
      case DateTime.sunday:
        return 'sun';
      case DateTime.saturday:
        return 'sat';
      case DateTime.friday:
        return 'fri';
      case DateTime.thursday:
        return 'thu';
      case DateTime.wednesday:
        return 'wed';
      case DateTime.tuesday:
        return 'tue';
      default:
        return 'mon'; // Fallback in case of an issue
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
