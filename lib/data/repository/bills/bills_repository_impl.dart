import 'package:dartz/dartz.dart';
import 'package:moneyy/data/models/bills/user_bills.dart';
import 'package:moneyy/data/sources/remote/bills/bills_firebase_services.dart';
import 'package:moneyy/domain/entities/bills/bills.dart';
import 'package:moneyy/domain/repository/bills/bills.dart';

class BillsRepositoryImpl implements BillsRepository {
  final BillsFirebaseService _firebaseService;

  BillsRepositoryImpl(this._firebaseService);


  // FETCH ALL BILLS
  @override
Future<Either<String, List<BillsEntity>>> fetchAllBills(int page, int pageSize) async {
  try {
    final eitherResult = await _firebaseService.fetchAllBills(pageSize: pageSize);

    return eitherResult.fold(
      (error) => Left(error),
      (billModels) {
        final List<BillsEntity> billsEntities = billModels.map((model) {
          return BillsEntity(
            uidOfBill: model.uidOfBill,
            billDescription: model.billDescription,
            billAmount: model.billAmount,
            billDueDate: model.billDueDate,
            billTitle: model.billTitle,
            addedDate: model.addedDate,
            paidStatus: model.paidStatus
          );
        }).toList();

        return Right(billsEntities);
      }
    );

  } catch (e) {
    return Left('Error fetching all bills: $e');
  }
}


  // TO ADD A BILL
  @override
  Future<Either> addBill(BillModel bills) async {
    try {
      final BillModel model = BillModel(
        uidOfBill: bills.uidOfBill,
        billAmount: bills.billAmount,
        billDescription: bills.billDescription,
        billDueDate: bills.billDueDate,
        billTitle: bills.billTitle,
        addedDate: bills.addedDate,
        paidStatus: bills.paidStatus
      );
      await _firebaseService.addBill(model);
      return Right(null);
    } catch (e) {
      return Left("Error adding bill: $e");
    }
  }
  

  // TO UPDATE THE EXPENSE
  @override
  Future<Either<String,String>> updateBill(String uidOfBill, BillModel updatedBill) async {
    try{
      final BillModel model = BillModel(
        uidOfBill: updatedBill.uidOfBill,
        billDescription: updatedBill.billDescription,
        billAmount: updatedBill.billAmount,
        billDueDate: updatedBill.billDueDate,
        billTitle: updatedBill.billTitle,
        addedDate: updatedBill.addedDate,
        paidStatus: updatedBill.paidStatus,
      );
      await _firebaseService.updateBill(uidOfBill, model);
      return Right("Expense has been added");
    } catch(e){
      return Left("Failed to update the Bill");
    }
  }


  // TO DELETE THE BILL
  @override
  Future<Either<String,String>> deleteBill(String uidOfBill) async {
    try{
      await _firebaseService.deleteBill(uidOfBill);
      return Right("Bill deleted succesfully");
    } catch(e){
      return Left("Failed to delete the Bill");
    }
  }




}
