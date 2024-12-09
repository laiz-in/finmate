// expenses_state.dart
import 'package:moneyy/domain/entities/income/income.dart';

abstract class IncomeState {}

// State to indicate income are loading
class IncomeLoading extends IncomeState {
  final bool isFirstFetch;
  IncomeLoading({this.isFirstFetch = true});
}

// State to indicate income have been successfully loaded
class IncomeLoaded extends IncomeState {
  final List<IncomeEntity> income;
  final bool hasMore; // Indicates if more expenses are available for lazy loading
  IncomeLoaded(this.income, {this.hasMore = true});
}

// State to indicate an error occurred while loading income
class IncomeError extends IncomeState {
  final String message;
  IncomeError(this.message);
}

// State to indicate the incme of the last 7 days have been successfully loaded
class LastSevenDayExpensesLoaded extends IncomeState {
  final Map<String, double> expensesMap;
  LastSevenDayExpensesLoaded(this.expensesMap);
}

// State to indicate filters have been cleared
class FiltersCleared extends IncomeState {}
