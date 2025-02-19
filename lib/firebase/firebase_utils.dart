import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

const String _usersCollection = 'users';
const String _spendingsCollection = 'spendings';
const String _incomeCollection = "income";

/// Optimized for instant cache response
Future<double> getMonthTotalIncome(String userId) {
  DateTime now = DateTime.now();
  DateTime startOfMonth = DateTime(now.year, now.month, 1);
  
  return _firestore
      .collection(_usersCollection)
      .doc(userId)
      .collection(_incomeCollection)
      .where('incomeDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
      .get(const GetOptions(source: Source.cache))
      .then((snapshot) => snapshot.docs.fold(
        0.0, 
        (sum, doc) => sum + (doc['incomeAmount'] as num).toDouble()
      ))
      .catchError((_) => 0.0);
}

/// Optimized monthly spending with cache-first approach
Stream<double> getMonthTotalSpending(String userId) {
  DateTime now = DateTime.now();
  DateTime startOfMonth = DateTime(now.year, now.month, 1);
  
  final query = _firestore
      .collection(_usersCollection)
      .doc(userId)
      .collection(_spendingsCollection)
      .where('spendingDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth));
      
  return query.snapshots().map((snapshot) => snapshot.docs.fold(
    0.0,
    (sum, doc) => sum + (doc['spendingAmount'] as num).toDouble()
  ));
}

/// Cache-only today's spending for instant response
Future<double> getTodayTotalSpending(String userId) {
  DateTime now = DateTime.now();
  DateTime startOfDay = DateTime(now.year, now.month, now.day);
  DateTime endOfDay = startOfDay.add(const Duration(days: 1))
      .subtract(const Duration(seconds: 1));
      
  return _firestore
      .collection(_usersCollection)
      .doc(userId)
      .collection(_spendingsCollection)
      .where('spendingDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
      .where('spendingDate', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
      .get(const GetOptions(source: Source.cache))
      .then((snapshot) => snapshot.docs.fold(
        0.0,
        (sum, doc) => sum + (doc['spendingAmount'] as num).toDouble()
      ))
      .catchError((_) => 0.0);
}

/// Cache-only today's income for instant response
Future<double> getTodayTotalIncome(String userId) {
  DateTime now = DateTime.now();
  DateTime startOfDay = DateTime(now.year, now.month, now.day);
  DateTime endOfDay = startOfDay.add(const Duration(days: 1))
      .subtract(const Duration(seconds: 1));
      
  return _firestore
      .collection(_usersCollection)
      .doc(userId)
      .collection(_incomeCollection)
      .where('incomeDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
      .where('incomeDate', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
      .get(const GetOptions(source: Source.cache))
      .then((snapshot) => snapshot.docs.fold(
        0.0,
        (sum, doc) => sum + (doc['incomeAmount'] as num).toDouble()
      ))
      .catchError((_) => 0.0);
}