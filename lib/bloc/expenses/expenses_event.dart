// expenses_event.dart
abstract class ExpensesEvent {}

class FetchAllExpensesEvent extends ExpensesEvent {}

class FetchMoreExpensesEvent extends ExpensesEvent {} // New event for lazy loading

class AddExpenseEvent extends ExpensesEvent {}

class SearchExpensesEvent extends ExpensesEvent {
  final String query; // Search query

  SearchExpensesEvent(this.query);
}

class FetchLastSevenDayExpensesEvent extends ExpensesEvent {}
