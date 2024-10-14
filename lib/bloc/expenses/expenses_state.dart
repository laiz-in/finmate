// expenses_state.dart
import 'package:moneyy/domain/entities/spending/expenses.dart';

abstract class ExpensesState {}

class ExpensesLoading extends ExpensesState {
  final bool isFirstFetch;

  ExpensesLoading({this.isFirstFetch = true});
}

class ExpensesLoaded extends ExpensesState {
  final List<ExpensesEntity> expenses;
  final bool hasMore; // Indicates if more expenses are available for lazy loading

  ExpensesLoaded(this.expenses, {this.hasMore = true});
}

class ExpensesError extends ExpensesState {
  final String message;

  ExpensesError(this.message);
}

class LastSevenDayExpensesLoaded extends ExpensesState {
  final Map<String, double> expensesMap;

  LastSevenDayExpensesLoaded(this.expensesMap);
}
