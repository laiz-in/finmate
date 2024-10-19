// expenses_state.dart
import 'package:moneyy/domain/entities/spending/expenses.dart';

abstract class ExpensesState {}

// expense loading state
class ExpensesLoading extends ExpensesState {
  final bool isFirstFetch;
  ExpensesLoading({this.isFirstFetch = true});
}


// expense loaded state
class ExpensesLoaded extends ExpensesState {
  final List<ExpensesEntity> expenses;
  final bool hasMore; // Indicates if more expenses are available for lazy loading
  ExpensesLoaded(this.expenses, {this.hasMore = true});
}

// error while loading an expense
class ExpensesError extends ExpensesState {
  final String message;
  ExpensesError(this.message);
}


// last 15 days expense loaded state
class LastSevenDayExpensesLoaded extends ExpensesState {
  final Map<String, double> expensesMap;

  LastSevenDayExpensesLoaded(this.expensesMap);
}
