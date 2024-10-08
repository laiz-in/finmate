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

  // Add an expense to the 'spendings' subcollection under the logged-in user's document
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

  // Fetch all expenses for the current logged-in user
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

  // Fetch the last three expenses for the current logged-in user
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
