import 'package:dartz/dartz.dart';
import 'package:moneyy/data/models/expenses/user_expenses.dart';
import 'package:moneyy/domain/entities/spending/expenses.dart';

abstract class ExpensesRepository {




  Future<Either<String, List<ExpensesEntity>>> fetchAllExpenses(int page, int pageSize);

  Future<Either<String, List<ExpensesEntity>>> fetchCompleteExpenses();


  Future<Either<String, List<ExpensesEntity>>> fetchLastThreeExpenses();

  Future<Either> updateExpense(String uidOfTransaction ,ExpensesModel updatedExpense);

  Future<Either> deleteExpense(String uidOfTransaction);


  Future<Either> addExpense(ExpensesModel expense);

  Future<Either<String, Map<String, double>>> fetchLastSevenDayExpenses();
}
