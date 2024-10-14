import 'package:dartz/dartz.dart';
import 'package:moneyy/data/models/expenses/user_expenses.dart';
import 'package:moneyy/domain/repository/total_spendings/expenses.dart';

class AddExpensesUseCase {
  final ExpensesRepository repository;

  AddExpensesUseCase(this.repository);

  Future<Either> call({ExpensesModel? params}) {
    return repository.addExpense(params!);
  }
}
