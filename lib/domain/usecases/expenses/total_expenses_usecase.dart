import 'package:dartz/dartz.dart';
import 'package:moneyy/domain/entities/spending/expenses.dart';
import 'package:moneyy/domain/repository/total_spendings/expenses.dart';

class TotalExpensesUseCase {
  final ExpensesRepository repository;

  TotalExpensesUseCase(this.repository);

  Future<Either<String, List<ExpensesEntity>>> call({required int page,required int pageSize}) {
    return repository.fetchAllExpenses(page, pageSize);
  }
}
