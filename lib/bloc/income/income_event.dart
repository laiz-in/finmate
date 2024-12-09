// expenses_event.dart

import 'package:moneyy/domain/entities/income/income.dart';

abstract class IncomeEvent {}

class FetchAllIncomeEvent extends IncomeEvent {}

class LoadMoreIncomeEvent extends IncomeEvent {}

class AddIncomeEvent extends IncomeEvent {
  final IncomeEntity income;
  AddIncomeEvent(this.income);
}


class DeleteIncomeEvent extends IncomeEvent {
  final String incomeId;
  DeleteIncomeEvent(this.incomeId);
}

class SearchIncomeEvent extends IncomeEvent {
  final String query;
  SearchIncomeEvent(this.query);
}


class SortByAmountEvent extends IncomeEvent {
  final bool ascending;
  SortByAmountEvent(this.ascending);
}

class FilterByCategoryEvent extends IncomeEvent {
  final String? category;
  FilterByCategoryEvent(this.category);
}

class FilterByDateRangeEvent extends IncomeEvent {
  final DateTime? startDate;
  final DateTime? endDate;
  FilterByDateRangeEvent(this.startDate, this.endDate);
}
class ResetIncomeEvent extends IncomeEvent {
  final int currentPage=1;
  final int pageSize=30;
}


class ClearFiltersEvent extends IncomeEvent {}

class RefreshIncomeEvent extends IncomeEvent {}