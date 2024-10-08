import 'package:dartz/dartz.dart';
import 'package:moneyy/domain/entities/spending/expenses.dart';

abstract class ExpensesRepository {
  Future<Either<String, List<ExpensesEntity>>> fetchAllExpenses();
  Future<Either<String, List<ExpensesEntity>>> fetchLastThreeExpenses();
  Future<Either<String, void>> addExpense(ExpensesEntity expense);
  Future<Either<String, Map<String, double>>> fetchLastSevenDayExpenses(); // New method
}
