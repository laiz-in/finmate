import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
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



  Future<Either<String,String>> updateExpense(String uidOfTransaction,ExpensesModel updateExpense) async{
    try{
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
            // get the user collection datas
            final userDocRef = FirebaseFirestore.instance.collection("users").doc(user.uid);
            final userDocSnapshot = await userDocRef.get();

            // find the current total spending
            final currentTotalSpending = userDocSnapshot.get('totalSpending') ?? 0.0;

            // get the specific spending collection
            final spendingRef = FirebaseFirestore.instance
                    .collection("users")
                    .doc(user.uid)
                    .collection("spendings")
                    .doc(uidOfTransaction);
            final spendingSnapshot = await spendingRef.get();
            
            final currentAmount = spendingSnapshot.get('spendingAmount') ?? 0.0;

            final newTotalSpending = currentTotalSpending - currentAmount + updateExpense.spendingAmount;
            await userDocRef.update({'totalSpending': newTotalSpending});

            // update the certain expense
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
              'createdAt': FieldValue.serverTimestamp(),
              'uidOfTransaction': uidOfTransaction,
            }
            );
            return Right("succesfully updated");
        }
      else{
        return Left("user is not found");
      }
    }catch (e){
      return Left("failed to update in firebase functions");
    }

  }



  // ADD EXPENSE
  Future<Either> addExpense(ExpensesModel expense) async {
    try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
            final userDocRef = FirebaseFirestore.instance.collection("users").doc(user.uid);
            final userDocSnapshot = await userDocRef.get();
            final currentTotalSpending = userDocSnapshot.get('totalSpending') ?? 0.0;
            final newTotalSpending = currentTotalSpending + expense.spendingAmount;

            await userDocRef.update({'totalSpending': newTotalSpending});
            final newSpendingRef = FirebaseFirestore.instance
                .collection("users")
                .doc(user.uid)
                .collection("spendings")
                .doc(); // Create a DocumentReference with a generated ID

            await newSpendingRef.set({
              'spendingAmount': expense.spendingAmount,
              'spendingCategory': expense.spendingCategory,
              'spendingDescription': expense.spendingDescription,
              'spendingDate': expense.spendingDate,
              'createdAt': FieldValue.serverTimestamp(),
              'uidOfTransaction': newSpendingRef.id, // Store the generated document ID
            });
            return Right("success");
          }
          else{
            return Left("User not found");
          }
    } catch (e) {
      return Left("error while adding ");
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
