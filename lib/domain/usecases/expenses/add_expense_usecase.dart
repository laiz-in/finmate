import 'package:dartz/dartz.dart';
import 'package:moneyy/domain/entities/spending/expenses.dart';
import 'package:moneyy/domain/repository/total_spendings/expenses.dart';

class AddExpensesUseCase {
  final ExpensesRepository repository;

  AddExpensesUseCase(this.repository);

  Future<Either<String, void>> call(ExpensesEntity expense) {
    return repository.addExpense(expense);
  }
}
