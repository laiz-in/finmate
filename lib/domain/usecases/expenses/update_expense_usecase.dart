import 'package:dartz/dartz.dart';
import 'package:moneyy/data/models/expenses/user_expenses.dart';
import 'package:moneyy/domain/repository/total_spendings/expenses.dart';

class UpdateExpensesUseCase {
  final ExpensesRepository repository;

  UpdateExpensesUseCase(this.repository);

  // Call method to update an expense based on the uidOfTransaction
  Future<Either<String, String>> call({required String uidOfTransaction, required ExpensesModel updatedExpense}) async {
    try {
      // Call the repository's update method and pass the uid and updated expense data
      await repository.updateExpense(uidOfTransaction, updatedExpense);
      
      // If successful, return a success message
      return Right("Expense updated successfully");
    } catch (e) {
      // If an error occurs, return the error message
      return Left("Failed to update expense: $e");
    }
  }
}
