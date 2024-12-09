import 'package:dartz/dartz.dart';
import 'package:moneyy/domain/repository/income/income.dart';

class DeleteIncomeUseCase {
  final IncomeRepository repository;

  DeleteIncomeUseCase(this.repository);

  // Call method to update an expense based on the uidOfTransaction
  Future<Either<String, String>> call({required String uidOfIncome}) async {
    try {
      // Call the repository's update method and pass the uid and updated expense data
      await repository.deleteIncome(uidOfIncome);
      
      // If successful, return a success message
      return Right("income has been deleted");
    } catch (e) {
      // If an error occurs, return the error message
      return Left("Failed to delete income: $e");
    }
  }
}
