import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/expense.dart';

class ExpenseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference _expensesRef(String uid) {
    return _firestore.collection('users').doc(uid).collection('expenses');
  }

  Future<void> setExpense(Expense expense) async {
    await _expensesRef(expense.uid).doc(expense.id).set(expense.toMap());
  }

  Future<void> deleteExpense(String uid, String expenseId) async {
    await _expensesRef(uid).doc(expenseId).delete();
  }

  Future<List<Expense>> fetchAll(String uid) async {
    final snapshot = await _expensesRef(uid)
        .get()
        .timeout(const Duration(seconds: 8));
    return snapshot.docs
        .map((doc) => Expense.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }
}