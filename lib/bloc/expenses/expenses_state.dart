// expenses_state.dart
import 'package:moneyy/domain/entities/spending/expenses.dart';

abstract class ExpensesState {}

// State to indicate expenses are loading
class ExpensesLoading extends ExpensesState {
  final bool isFirstFetch;
  ExpensesLoading({this.isFirstFetch = true});
}

// State to indicate expenses have been successfully loaded
class ExpensesLoaded extends ExpensesState {
  final List<ExpensesEntity> expenses;
  final bool hasMore; // Indicates if more expenses are available for lazy loading
  ExpensesLoaded(this.expenses, {this.hasMore = true});
}

// State to indicate an error occurred while loading expenses
class ExpensesError extends ExpensesState {
  final String message;
  ExpensesError(this.message);
}

// State to indicate the expenses of the last 7 days have been successfully loaded
class LastSevenDayExpensesLoaded extends ExpensesState {
  final Map<String, double> expensesMap;
  LastSevenDayExpensesLoaded(this.expensesMap);
}

// State to indicate filters have been cleared
class FiltersCleared extends ExpensesState {}
