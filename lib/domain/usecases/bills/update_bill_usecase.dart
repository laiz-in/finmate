import 'package:dartz/dartz.dart';
import 'package:moneyy/data/models/bills/user_bills.dart';
import 'package:moneyy/domain/repository/bills/bills.dart';

class UpdateBillUsecase {
  final BillsRepository repository;

  UpdateBillUsecase(this.repository);

  // Call method to update an expense based on the uidOfTransaction
  Future<Either<String, String>> call({required String uidOfBill, required BillModel updatedBill}) async {
    try {
      // Call the repository's update method and pass the uid and updated expense data
      await repository.updateBill(uidOfBill, updatedBill);
      
      // If successful, return a success message
      return Right("bill updated successfully");
    } catch (e) {
      // If an error occurs, return the error message
      return Left("Failed to update bill: $e");
    }
  }
}
