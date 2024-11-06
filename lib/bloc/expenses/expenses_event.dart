// expenses_event.dart

import 'package:moneyy/domain/entities/spending/expenses.dart';

abstract class ExpensesEvent {}

class FetchAllExpensesEvent extends ExpensesEvent {}

class FetchMoreExpensesEvent extends ExpensesEvent {}

class AddExpenseEvent extends ExpensesEvent {
  final ExpensesEntity expense;
  AddExpenseEvent(this.expense);
}

class SearchExpensesEvent extends ExpensesEvent {
  final String query;
  SearchExpensesEvent(this.query);
}

class FetchLastSevenDayExpensesEvent extends ExpensesEvent {}

class SortByAmountEvent extends ExpensesEvent {
  final bool ascending;
  SortByAmountEvent(this.ascending);
}

class FilterByCategoryEvent extends ExpensesEvent {
  final String? category;
  FilterByCategoryEvent(this.category);
}

class FilterByDateRangeEvent extends ExpensesEvent {
  final DateTime? startDate;
  final DateTime? endDate;
  FilterByDateRangeEvent(this.startDate, this.endDate);
}
class ResetExpensesEvent extends ExpensesEvent {}


class ClearFiltersEvent extends ExpensesEvent {}

class RefreshExpensesEvent extends ExpensesEvent {}