import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; // Add this dependency
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart'; // Add this dependency
import 'package:moneyy/data/models/bills/user_bills.dart';

class BillsFirebaseService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final Logger _logger;
  final Connectivity _connectivity;
  
  // MAXIMUM RETRY ATTEMPTS
  static const int _maxRetries = 3;
  
  // SINGLETON PATTERN
  static BillsFirebaseService? _instance;
  
  // PRIVATE CONSTRUCTOR
  BillsFirebaseService._({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    Logger? logger,
    Connectivity? connectivity,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance,
      _logger = logger ?? Logger(),
      _connectivity = connectivity ?? Connectivity();
  
  // FACTORY CONSTRUCTOR
  factory BillsFirebaseService() {
    _instance ??= BillsFirebaseService._();
    return _instance!;
  }

  // CHECK INTERNET CONNECTION
  Future<bool> _isOnline() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  // RETRY MECHANISM OFR FIREBASE OPERATIONS
  Future<T> _retryOperation<T>(Future<T> Function() operation) async {
    int attempts = 0;
    while (attempts < _maxRetries) {
      try {
        return await operation();
      } catch (e) {
        attempts++;
        if (attempts == _maxRetries) rethrow;
        await Future.delayed(Duration(seconds: attempts * 2)); // Exponential backoff
      }
    }
    throw Exception('Operation failed after $_maxRetries attempts');
  }

  // GET CURRENT USER ID
  String? _getCurrentUserId() {
    final user = _auth.currentUser;
    if (user == null) {
      _logger.w('No user currently logged in');
      return null;
    }
    return user.uid;
  }

  // VALIDATION OFR BILL DATAS
  bool _validateBillData(BillModel bill) {
    if (bill.billAmount <= 0) {
      _logger.w('Invalid bill amount: ${bill.billAmount}');
      return false;
    }
    if (bill.billTitle.isEmpty) {
      _logger.w('Empty bill title');
      return false;
    }
    if (bill.billDueDate.isBefore(DateTime.now().subtract(const Duration(days: 365 * 2)))) {
      _logger.w('Bill due date too old: ${bill.billDueDate}');
      return false;
    }
    return true;
  }


  // UPDATE BILL
  Future<Either<String, String>> updateBill(String uidOfBill, BillModel updatedBill) async {
    try {
      if (!_validateBillData(updatedBill)) {
        return left('INVALID_BILL_DATA');
      }

      final userId = _getCurrentUserId();
      if (userId == null) return left('USER_NOT_LOGGED_IN');

      final billsRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('bills')
          .doc(uidOfBill);


      _retryOperation(() => billsRef.set({
        'uidOfBill': updatedBill.uidOfBill,
        'billAmount': updatedBill.billAmount,
        'billDescription': updatedBill.billDescription,
        'billTitle': updatedBill.billTitle,
        'addedDate':updatedBill.addedDate,
        'billDueDate': updatedBill.billDueDate,
        'paidStatus': updatedBill.paidStatus,
      }, SetOptions(merge: true)));

      final isOnline = await _isOnline();

      return right(isOnline ? 'SUCCESS' : 'SUCCESS_OFFLINE');

    } catch (e) {
      _logger.e('Error updating bill', e);
      if (e is FirebaseException) {
        switch (e.code) {
          case 'network-request-failed':
            return right('SUCCESS_OFFLINE');
          case 'permission-denied':
            return left('PERMISSION_DENIED');
          case 'not-found':
            return left('BILL_NOT_FOUND');
          default:
            return left('FIREBASE_ERROR: ${e.code}');
        }
      }
      return left('UNKNOWN_ERROR: ${e.toString()}');
    }
  }

  // ADD BILL
  Future<Either<String, String>> addBill(BillModel bill) async {
    try {
      if (!_validateBillData(bill)) {
        return left('INVALID_BILL_DATA');
      }

      final userId = _getCurrentUserId();
      if (userId == null) return left('USER_NOT_LOGGED_IN');

      final batch = _firestore.batch();
      final newBillRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('bills')
          .doc();

      final billData = {
        'billAmount': bill.billAmount,
        'billDescription': bill.billDescription,
        'billTitle': bill.billTitle,
        'billDueDate': bill.billDueDate,
        'addedDate': Timestamp.fromDate(DateTime.now()),
        'paidStatus': bill.paidStatus,
        'uidOfBill': newBillRef.id,
      };
      batch.set(newBillRef, billData);
      _retryOperation(() => batch.commit());

      final isOnline = await _isOnline();
      return right(isOnline ? 'SUCCESS' : 'SUCCESS_OFFLINE');

    } catch (e) {
      _logger.e('Error adding bill', e);
      return _handleFirebaseError(e);
    }
  }


  // FETCH ALL BILLS
  Future<Either<String, List<BillModel>>> fetchAllBills({
  DateTime? lastAddedDate,
  required int pageSize,
  }) async {
  try {
    final userId = _getCurrentUserId();
    if (userId == null) {
      return left('USER_NOT_LOGGED_IN');
    }

    if (pageSize <= 0 || pageSize > 100) {
      return left('INVALID_PAGE_SIZE');
    }

    Query query = _firestore
        .collection('users')
        .doc(userId)
        .collection('bills')
        .orderBy('addedDate', descending: true)
        .limit(pageSize);

    if (lastAddedDate != null) {
      query = query.startAfter([Timestamp.fromDate(lastAddedDate)]);
    }

    QuerySnapshot snapshot;
    final isOnline = await _isOnline();
    if (isOnline) {
      try {
        snapshot = await query.get(const GetOptions(source: Source.server));
      } catch (e) {
        snapshot = await query.get(const GetOptions(source: Source.cache));
      }
    } else {
      snapshot = await query.get(const GetOptions(source: Source.cache));
    }

    final List<BillModel> bills = snapshot.docs.map((doc) {
      try {
        return BillModel.fromJson(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      } catch (e) {
        return null;
      }
    }).whereType<BillModel>().toList();

    return right(bills);

  } on FirebaseAuthException catch (e) {
    _logger.e('Firebase Auth Error:', e);
    return left('AUTH_ERROR: ${e.message}');
  } on FirebaseException catch (e) {
    _logger.e('Firebase Error:', e);
    return left('FIREBASE_ERROR: ${e.message}');
  } catch (e) {
    _logger.e('Unknown Error:', e);
    return left('UNKNOWN_ERROR');
  }
}

  //DELETE A BILL
  Future<Either<String, String>> deleteBill(String uidOfBill) async {
    try {
      final userId = _getCurrentUserId();
      if (userId == null) return left('USER_NOT_LOGGED_IN');

      final batch = _firestore.batch();
      final billRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('bills')
          .doc(uidOfBill);

      DocumentSnapshot billSnapshot;
      try {
        billSnapshot = await billRef.get(const GetOptions(source: Source.server));
      } catch (e) {
        billSnapshot = await billRef.get(const GetOptions(source: Source.cache));
      }

      if (!billSnapshot.exists) {
        return left('BILL_NOT_FOUND');
      }

      batch.delete(billRef);

      await _retryOperation(() => batch.commit());

      final isOnline = await _isOnline();
      return right(isOnline ? 'SUCCESS' : 'SUCCESS_OFFLINE');

    } catch (e) {
      _logger.e('Error deleting bill', e);
      return _handleFirebaseError(e);
    }
  }

 // HANDLING FIREBAS ERROR
  Either<String, T> _handleFirebaseError<T>(dynamic error) {
    if (error is FirebaseException) {
      switch (error.code) {
        case 'network-request-failed':
          return left('NETWORK_ERROR');
        case 'permission-denied':
          return left('PERMISSION_DENIED');
        case 'not-found':
          return left('NOT_FOUND');
        case 'already-exists':
          return left('ALREADY_EXISTS');
        case 'failed-precondition':
          return left('FAILED_PRECONDITION');
        default:
          return left('FIREBASE_ERROR: ${error.code}');
      }
    }
    return left('UNKNOWN_ERROR: ${error.toString()}');
  }

  void dispose() {
    _logger.close();
  }
}