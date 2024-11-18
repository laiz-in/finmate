import 'package:dartz/dartz.dart';
import 'package:moneyy/domain/repository/bills/bills.dart';

class DeleteBillUsecase {
  final BillsRepository repository;

  DeleteBillUsecase(this.repository);

  // Call method to update an expense based on the uidOfTransaction
  Future<Either<String, String>> call({required String uidOfBill}) async {
    try {
      // Call the repository's update method and pass the uid and updated bill data
      await repository.deleteBill(uidOfBill);
      
      // If successful, return a success message
      return Right("Bill has been deleted");
    } catch (e) {
      // If an error occurs, return the error message
      return Left("Failed to delete bill: $e");
    }
  }
}
