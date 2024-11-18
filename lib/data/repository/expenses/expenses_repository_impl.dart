import 'package:dartz/dartz.dart';
import 'package:moneyy/data/models/expenses/user_expenses.dart';
import 'package:moneyy/data/sources/expenses/expenses_firebase_services.dart';
import 'package:moneyy/domain/entities/spending/expenses.dart';
import 'package:moneyy/domain/repository/total_spendings/expenses.dart';

class ExpensesRepositoryImpl implements ExpensesRepository {
  final ExpensesFirebaseService _firebaseService;

  ExpensesRepositoryImpl(this._firebaseService);


  // FETCH ALL EXPENSES
  @override
  Future<Either<String, List<ExpensesEntity>>> fetchAllExpenses(page,pageSize) async {
    try {
      final List<ExpensesModel> expensesModels = await _firebaseService.fetchAllExpenses(pageSize:pageSize);
      final List<ExpensesEntity> expensesEntities = expensesModels.map((model) {
        return ExpensesEntity(
          uidOfTransaction: model.uidOfTransaction,
          spendingDescription: model.spendingDescription,
          spendingCategory: model.spendingCategory,
          spendingAmount: model.spendingAmount,
          spendingDate: model.spendingDate,
          createdAt: model.createdAt,
        );
      }).toList();
      return Right(expensesEntities);
    } catch (e) {
      return Left("Error fetching all expenses: $e");
    }
  }



  // FETCH LAST 3 EXPENSES
  @override
  Future<Either<String, List<ExpensesEntity>>> fetchLastThreeExpenses() async {
    try {
      final List<ExpensesModel> expensesModels = await _firebaseService.fetchLastThreeExpenses();
      final List<ExpensesEntity> expensesEntities = expensesModels.map((model) {
        return ExpensesEntity(
          uidOfTransaction: model.uidOfTransaction,
          spendingDescription: model.spendingDescription,
          spendingCategory: model.spendingCategory,
          spendingAmount: model.spendingAmount,
          spendingDate: model.spendingDate,
          createdAt: model.createdAt,
        );
      }).toList();
      return Right(expensesEntities);
    } catch (e) {
      return Left("Error fetching last three expenses: $e");
    }
  }



  // TO ADD AN EXPENSE
  @override
  Future<Either> addExpense(ExpensesModel expense) async {
    try {
      final ExpensesModel model = ExpensesModel(
        uidOfTransaction: expense.uidOfTransaction,
        spendingDescription: expense.spendingDescription,
        spendingCategory: expense.spendingCategory,
        spendingAmount: expense.spendingAmount,
        spendingDate: expense.spendingDate,
        createdAt: expense.createdAt,
      );
      await _firebaseService.addExpense(model);
      return Right(null);
    } catch (e) {
      return Left("Error adding expense: $e");
    }
  }
  

  // TO UPDATE THE EXPENSE
  @override
  Future<Either<String,String>> updateExpense(String uidOfTransaction, ExpensesModel updatedExpense) async {
    try{
      final ExpensesModel model = ExpensesModel(
        uidOfTransaction: updatedExpense.uidOfTransaction,
        spendingDescription: updatedExpense.spendingDescription,
        spendingCategory: updatedExpense.spendingCategory,
        spendingAmount: updatedExpense.spendingAmount,
        spendingDate: updatedExpense.spendingDate,
        createdAt: updatedExpense.createdAt,
      );
      await _firebaseService.updateExpense(uidOfTransaction, model);
      return Right("Expense updated succesfully");
    } catch(e){
      return Left("Failed to update the expense");
    }
  }


  // TO DELETE THE EXPENSE
  @override
  Future<Either<String,String>> deleteExpense(String uidOfTransaction) async {
    try{
      await _firebaseService.deleteExpenses(uidOfTransaction);
      return Right("Expense deleted succesfully");
    } catch(e){
      return Left("Failed to delete the expense");
    }
  }


  // FETCH LAST 15 DAY EXPENSES IN TOTAL
  @override
  Future<Either<String, Map<String, double>>> fetchLastSevenDayExpenses() async {
    try {
      final expensesPerDay = await _firebaseService.fetchLastSevenDayExpenses();
      return Right(expensesPerDay);
    } catch (e) {
      return Left('Error fetching last seven day expenses: $e');
    }
  }
}
