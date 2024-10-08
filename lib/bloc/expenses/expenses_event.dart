import 'package:moneyy/domain/entities/spending/expenses.dart';

abstract class ExpensesEvent {}

class FetchAllExpensesEvent extends ExpensesEvent {}

class FetchLastThreeExpensesEvent extends ExpensesEvent {}

class FetchLastSevenDayExpensesEvent extends ExpensesEvent {} // New event


class AddExpenseEvent extends ExpensesEvent {
  final ExpensesEntity expense;

  AddExpenseEvent(this.expense);
}
