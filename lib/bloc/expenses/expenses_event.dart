// expenses_event.dart
abstract class ExpensesEvent {}

// to fetch all expenses
class FetchAllExpensesEvent extends ExpensesEvent {}


// fetch more pxenses
class FetchMoreExpensesEvent extends ExpensesEvent {} // New event for lazy loading


// to add an expense
class AddExpenseEvent extends ExpensesEvent {}


// to search an expense
class SearchExpensesEvent extends ExpensesEvent {
  final String query;
  SearchExpensesEvent(this.query);
}

// fetch last 15 days total expense
class FetchLastSevenDayExpensesEvent extends ExpensesEvent {}
