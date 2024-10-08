import 'package:moneyy/domain/entities/spending/expenses.dart';

abstract class ExpensesState {}

class ExpensesLoading extends ExpensesState {}

class ExpensesLoaded extends ExpensesState {
  final List<ExpensesEntity> expenses;

  ExpensesLoaded(this.expenses);
}

class ExpensesError extends ExpensesState {
  final String message;

  ExpensesError(this.message);
}

class LastSevenDayExpensesLoaded extends ExpensesState {
  final Map<String, double> expenses;

  LastSevenDayExpensesLoaded(this.expenses);

  @override
  List<Object> get props => [expenses];
}