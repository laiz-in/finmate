
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:moneyy/data/models/income/user_income.dart';

class IncomeFirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

// Fetch current logged-in user's ID
String? _getCurrentUserId() {
  final User? currentUser = _auth.currentUser;
  return currentUser?.uid;
}

// FETCH COMPLETE INCOME
Future<List<IncomeModel>> fetchCompleteIncome() async {
  try {
    final String? userId = _getCurrentUserId();
    if (userId == null) {
      throw Exception("User is not logged in");
    }

    // Start building the query
    Query query = _firestore
        .collection('users')
        .doc(userId)
        .collection('income')
        .orderBy('incomeDate', descending: true);

    

    // Fetch documents from the 'spendings' subcollection with pagination
    try{
    final QuerySnapshot snapshot = await query.get(GetOptions(source: Source.cache));
    // Map documents to ExpensesModel
    final List<IncomeModel> income = snapshot.docs.map((doc) {
      return IncomeModel.fromJson(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
    }).toList();
        return income;
    }
    catch (e){
    final QuerySnapshot snapshot = await query.get(GetOptions(source: Source.server));
    // Map documents to ExpensesModel
    final List<IncomeModel> income = snapshot.docs.map((doc) {
      return IncomeModel.fromJson(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
    }).toList();
    return income;
    }


  } catch (e) {
    return [];
  }
}

// TO UPDATE INCOME
  Future<Either<String,String>> updateIncome(String uidOfIncome,IncomeModel updateIncome) async{
    try{
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {


            // update the certain expense
            final newIncomeRef = FirebaseFirestore.instance
                .collection("users")
                .doc(user.uid)
                .collection("income")
                .doc(uidOfIncome);


            newIncomeRef.update({
              'incomeAmount': updateIncome.incomeAmount,
              'incomeCategory': updateIncome.incomeCategory,
              'incomeRemarks': updateIncome.incomeRemarks,
              'incomeDate': updateIncome.incomeDate,
              'createdAt': Timestamp.fromDate(DateTime.now()),
              'uidOfIncome': uidOfIncome,
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

// ADD INCOME
  Future<Either> addIncome(IncomeModel income) async {
    try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {

            final newIncomeRef = FirebaseFirestore.instance
                .collection("users")
                .doc(user.uid)
                .collection("income")
                .doc(); // Create a DocumentReference with a generated ID

            newIncomeRef.set({
              'incomeAmount': income.incomeAmount,
              'incomeCategory': income.incomeCategory,
              'incomeRemarks': income.incomeRemarks,
              'incomeDate': income.incomeDate,
              'createdAt': Timestamp.fromDate(DateTime.now()),
              'uidOfIncome': newIncomeRef.id, // Store the generated document ID
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

// FETCH ALL INCOME
Future<List<IncomeModel>> fetchAllIncome({DateTime? lastIncomeDate, required int pageSize}) async {
  try {
    final String? userId = _getCurrentUserId();
    if (userId == null) {
      throw Exception("User is not logged in");
    }

    // Start building the query
    Query query = _firestore
        .collection('users')
        .doc(userId)
        .collection('income')
        .orderBy('incomeDate', descending: true)
        .limit(pageSize);

    // Use startAfter based on lastSpendingDate if provided
    if (lastIncomeDate != null) {
      query = query.startAfter([lastIncomeDate]);
    }

    // Fetch documents from the 'spendings' subcollection with pagination
    try{
    final QuerySnapshot snapshot = await query.get(GetOptions(source: Source.cache));
    // Map documents to ExpensesModel
    final List<IncomeModel> income = snapshot.docs.map((doc) {
      return IncomeModel.fromJson(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
    }).toList();
        return income;
    }
    catch (e){
    final QuerySnapshot snapshot = await query.get(GetOptions(source: Source.server));
    // Map documents to ExpensesModel
    final List<IncomeModel> income = snapshot.docs.map((doc) {
      return IncomeModel.fromJson(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
    }).toList();
    return income;
    }


  } catch (e) {
    return [];
  }
}

// LAST 3 INCOME
Future<List<IncomeModel>> fetchLastThreeIncome() async {
    try {
      final String? userId = _getCurrentUserId();

      if (userId == null) {
        throw Exception("User is not logged in");
      }

      // Fetch the last 3 documents from the 'spendings' subcollection
      Query query = _firestore
        .collection('users')
        .doc(userId)
        .collection('income')
        .limit(3)
        .orderBy("incomeDate", descending: true);

      try{
            final QuerySnapshot snapshot = await query.get(GetOptions(source: Source.cache));
            final List<IncomeModel> income = snapshot.docs.map((doc) {
            return IncomeModel.fromJson(
            doc.data() as Map<String, dynamic>,
            doc.id,
          );
          }).toList();
              return income;
            }
      catch (e){
            final QuerySnapshot snapshot = await query.get(GetOptions(source: Source.server));
            final List<IncomeModel> income = snapshot.docs.map((doc) {
                  return IncomeModel.fromJson(
                    doc.data() as Map<String, dynamic>,
                    doc.id,
                  );
                }).toList();
        return income;
      }
      

    } catch (e) {
      return [];
    }
  }

// DELETE THE INCOME
Future<Either<String, String>> deleteIncome(String uidOfIncome) async {
  try {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {


      // Get the specific spending document
      final incomeRef = FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .collection("income")
          .doc(uidOfIncome);
      final incomeSnapshot = await incomeRef.get();

      // Ensure the spending document exists
      if (!incomeSnapshot.exists) {
        return Left("income not found");
      }

      // Delete the document from the "spendings" collection
      incomeRef.delete();

      return Right("Successfully deleted the income");
    } else {
      return Left("User is not logged in");
    }
  } catch (e) {
    return Left("Failed to delete income: ${e.toString()}");
  }
}

// THIS MONTH INCOME
Future<Either<String,double>> fetchThisMonthIncome() async {
try {
    final user = FirebaseAuth.instance.currentUser;
    if(user!=null){
    double thisMonthIncome = 0.0;
    DateTime now = DateTime.now();
    DateTime startOfMonth = DateTime(now.year, now.month, 1); // 1st of the current month at 12:00 AM
    DateTime currentTime = now; // Current date and time

    QuerySnapshot incomeSnapshot = await _firestore
        .collection("users")
        .doc(user.uid)
        .collection("income")
        .where('incomeDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .where('incomeDate', isLessThanOrEqualTo: Timestamp.fromDate(currentTime))
        .get(GetOptions(source: Source.cache));

    for (var doc in incomeSnapshot.docs) {
      thisMonthIncome += (doc['incomeAmount'] as num).toDouble();
    }
    return Right(thisMonthIncome);
    }
    else{
      return Left("user is not logged in");
    }
  } catch (e) {
    return Left("Failed to fetch this month total");
  }
}

// THIS WEEK INCOME
Future<Either<String, double>> fetchThisWeekIncome() async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      double thisWeekIncome = 0.0;
      DateTime now = DateTime.now();
      // Calculate the start of the week (last Thursday)
      int daysSinceThursday = (now.weekday + 3) % 7; // Ensures Thursday is day 0 of the week
      DateTime startOfWeek = DateTime(now.year, now.month, now.day).subtract(Duration(days: daysSinceThursday));
      
      DateTime currentTime = now; // Current date and time

      QuerySnapshot incomeSnapshot = await _firestore
          .collection("users")
          .doc(user.uid)
          .collection("income")
          .where('incomeDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfWeek))
          .where('incomeDate', isLessThanOrEqualTo: Timestamp.fromDate(currentTime))
          .get();

      for (var doc in incomeSnapshot.docs) {
        thisWeekIncome += (doc['incomeAmount'] as num).toDouble();
      }
      return Right(thisWeekIncome);
    } else {
      return Left("User is not logged in");
    }
  } catch (e) {
    return Left("Failed to fetch this week total");
  }
}

// THIS YEAR INCOME
Future<Either<String, double>> fetchThisYearIncome() async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      double thisYearIncome = 0.0;
      DateTime now = DateTime.now();
      DateTime startOfYear = DateTime(now.year, 1, 1); // 1st of January of the current year at 12:00 AM
      DateTime currentTime = now; // Current date and time

      QuerySnapshot incomeSnapshot = await _firestore
          .collection("users")
          .doc(user.uid)
          .collection("income")
          .where('incomeDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfYear))
          .where('incomeDate', isLessThanOrEqualTo: Timestamp.fromDate(currentTime))
          .get();

      for (var doc in incomeSnapshot.docs) {
        thisYearIncome += (doc['incomeAmount'] as num).toDouble();
      }
      return Right(thisYearIncome);
    } else {
      return Left("User is not logged in");
    }
  } catch (e) {
    return Left("Failed to fetch this year total");
  }
}

// TODAY'S INCOME
Future<Either<String, double>> fetchTotalIncome() async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      double todaysIncome = 0.0;
      DateTime now = DateTime.now();
      DateTime startOfDay = DateTime(now.year, now.month, now.day); // Start of today
      DateTime endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59); // End of today

      QuerySnapshot incomeSnapshot = await _firestore
          .collection("users")
          .doc(user.uid)
          .collection("income")
          .where('incomeDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('incomeDate', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .get();

      for (var doc in incomeSnapshot.docs) {
        todaysIncome += (doc['incomeAmount'] as num).toDouble();
      }
      return Right(todaysIncome);
    } else {
      return Left("User is not logged in");
    }
  } catch (e) {
    return Left("Failed to fetch today's total income: ${e.toString()}");
  }
}
}