import 'package:dartz/dartz.dart';
import 'package:moneyy/domain/repository/total_spendings/expenses.dart';

class LastSevenDayExpensesUseCase {
  final ExpensesRepository repository;

  LastSevenDayExpensesUseCase(this.repository);

  Future<Either<String, Map<String, double>>> call() async {
    return await repository.fetchLastSevenDayExpenses();
  }
}
