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


            await newIncomeRef.update({
              'incomeAmount': updateIncome.incomeAmount,
              'incomeCategory': updateIncome.incomeCategory,
              'incomeRemarks': updateIncome.incomeRemarks,
              'incomeDate': updateIncome.incomeDate,
              'createdAt': FieldValue.serverTimestamp(),
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

            await newIncomeRef.set({
              'incomeAmount': income.incomeAmount,
              'incomeCategory': income.incomeCategory,
              'incomeRemarks': income.incomeRemarks,
              'incomeDate': income.incomeDate,
              'createdAt': FieldValue.serverTimestamp(),
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

    // Use startAfter based on lastincomeDate if provided
    if (lastIncomeDate != null) {
      query = query.startAfter([lastIncomeDate]);
    }

    // Fetch documents from the 'income' subcollection with pagination
    final QuerySnapshot snapshot = await query.get();

    // Map documents to IncomeModel
    final List<IncomeModel> income = snapshot.docs.map((doc) {
      return IncomeModel.fromJson(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
    }).toList();

    return income;
  } catch (e) {
    throw Exception("Failed to fetch income: $e");
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
      final QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('income')
          .orderBy('IncomeDate', descending: true)
          .limit(3)
          .get();

      // Map documents to ExpensesModel
      final List<IncomeModel> income = snapshot.docs.map((doc) {
        return IncomeModel.fromJson(
          doc.data() as Map<String, dynamic>,
          doc.id, // Use the document ID as uidOfTransaction
        );
      }).toList();

      return income;
    } catch (e) {
      throw Exception("Failed to fetch last three income: $e");
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
      await incomeRef.delete();

      return Right("Successfully deleted the income");
    } else {
      return Left("User is not logged in");
    }
  } catch (e) {
    return Left("Failed to delete income: ${e.toString()}");
  }
}


}
