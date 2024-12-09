import 'package:dartz/dartz.dart';
import 'package:moneyy/data/models/income/user_income.dart';
import 'package:moneyy/domain/repository/income/income.dart';

class UpdateIncomeUseCase {
  final IncomeRepository repository;

  UpdateIncomeUseCase(this.repository);

  // Call method to update an expense based on the uidOfTransaction
  Future<Either<String, String>> call({required String uidOfIncome, required IncomeModel updatedIncome}) async {
    try {
      // Call the repository's update method and pass the uid and updated expense data
      await repository.updateIncome(uidOfIncome, updatedIncome);
      
      // If successful, return a success message
      return Right("income updated successfully");
    } catch (e) {
      // If an error occurs, return the error message
      return Left("Failed to update income: $e");
    }
  }
}
