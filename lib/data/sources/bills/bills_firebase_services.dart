import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:moneyy/data/models/bills/user_bills.dart';

class BillsFirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Fetch current logged-in user's ID
  String? _getCurrentUserId() {
    final User? currentUser = _auth.currentUser;
    return currentUser?.uid;
  }


  // TO UPDATE BILL
  Future<Either<String,String>> updateBill(String uidOfBill,BillModel updatedBill) async{
    try{
        final user = FirebaseAuth.instance.currentUser;

        if (user != null) {

            // get the specific bills collection
            final billsRef = FirebaseFirestore.instance
                    .collection("users")
                    .doc(user.uid)
                    .collection("bills")
                    .doc(uidOfBill);


            await billsRef.update({
              'uidOfBill': updatedBill.uidOfBill,
              'billAmount': updatedBill.billAmount,
              'billDescription': updatedBill.billDescription,
              'billTitle': updatedBill.billTitle,
              'addedDate': FieldValue.serverTimestamp(),
              'billDueDate':updatedBill.billDueDate,
              'paidStatus': updatedBill.paidStatus,
            }
            );
        return right("SUCCESS");
        }
        else
        {
          return left("USER NOT LOGGED IN");
        }
    }
    catch(e){
          return left("FAILED");
    }
  }


  // ADD BILL
  Future<Either> addBill(BillModel bill) async {
    try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {

            final newBillRef = FirebaseFirestore.instance
                .collection("users")
                .doc(user.uid)
                .collection("bills")
                .doc(); // Create a DocumentReference with a generated ID

            await newBillRef.set({
              'billAmount': bill.billAmount,
              'billDescription': bill.billDescription,
              'billTitle': bill.billTitle,
              'billDueDate': bill.billDueDate,
              'addedDate': FieldValue.serverTimestamp(),
              'paidStatus': bill.paidStatus,
              'uidOfBill': newBillRef.id, // Store the generated document ID
            });
            return Right("success");
          }
          else{
            return Left("User not found");
          }    } catch (e) {
      return Left("Failed to add the bill");
    }
  }


  // FETCH ALL BILLS
  Future<List<BillModel>> fetchAllBills({DateTime? lastAddedDate, required int pageSize}) async {
        try {
        final user = FirebaseAuth.instance.currentUser;
          if (user != null) {

              // Start building the query
              Query query = _firestore
                  .collection('users')
                  .doc(user.uid)
                  .collection('bills')
                  .orderBy('addedDate', descending: true)
                  .limit(pageSize);

              // Use startAfter based on lastSpendingDate if provided
              if (lastAddedDate != null) {
                query = query.startAfter([lastAddedDate]);
              }

              // Fetch documents from the 'spendings' subcollection with pagination
              final QuerySnapshot snapshot = await query.get();

              // Map documents to ExpensesModel
              final List<BillModel> bills = snapshot.docs.map((doc) {
                return BillModel.fromJson(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                );
              }).toList();
              return bills;
          }
          else{
          throw Exception("User not logged in");
          }
      
        } catch (e) {
          throw Exception("Failed to fetch expenses: $e");
        }
      }


  // DELETE THE EXPENSE
  Future<Either<String, String>> deleteBill(String uidOfBill) async {
  try {
    return right("sucecess");
  } catch (e) {
    return Left("Failed to delete expense: ${e.toString()}");
  }
}



}
