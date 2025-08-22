// expenses_state.dart
import 'package:moneyy/domain/entities/expenses/expenses.dart';

abstract class ExpensesState {}

// WHILE EXPENSES ARE LOADING
class ExpensesLoading extends ExpensesState {
  final bool isFirstFetch;
  ExpensesLoading({this.isFirstFetch = true});
}

// WHEN EXPENSES ARE LOADED
class ExpensesLoaded extends ExpensesState {
  final List<ExpensesEntity> expenses;
  final bool hasMore; // Indicates if more expenses are available for lazy loading
  ExpensesLoaded(this.expenses, {this.hasMore = true});
}

// WHEN ERROR OCCURED WHILE LOADING
class ExpensesError extends ExpensesState {
  final String message;
  ExpensesError(this.message);
}

// 15 DAYS EXPENSES LOADED
class LastSevenDayExpensesLoaded extends ExpensesState {
  final Map<String, double> expensesMap;
  LastSevenDayExpensesLoaded(this.expensesMap);
}


// WHEN FILTERS ARE CLEARED
class FiltersCleared extends ExpensesState {}
