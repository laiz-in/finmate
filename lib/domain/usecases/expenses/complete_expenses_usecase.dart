import 'package:dartz/dartz.dart';
import 'package:moneyy/domain/entities/expenses/expenses.dart';
import 'package:moneyy/domain/repository/total_spendings/expenses.dart';

class CompleteExpensesUsecase {
  final ExpensesRepository repository;

  CompleteExpensesUsecase(this.repository);

  Future<Either<String, List<ExpensesEntity>>> call() {
    return repository.fetchCompleteExpenses();
  }
}
