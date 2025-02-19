// FILEPATH: /C:/Users/Hp/Desktop/moneyy - Copy/moneyy/lib/bloc/income/income_state.dart
// EXPENSES_STATE.DART
import 'package:moneyy/domain/entities/income/income.dart';

abstract class IncomeState {}

// STATE TO INDICATE INCOME ARE LOADING
class IncomeLoading extends IncomeState {
  final bool isFirstFetch;
  IncomeLoading({this.isFirstFetch = true});
}

// STATE TO INDICATE INCOME HAVE BEEN SUCCESSFULLY LOADED
class IncomeLoaded extends IncomeState {
  final List<IncomeEntity> income;
  final bool hasMore; // INDICATES IF MORE EXPENSES ARE AVAILABLE FOR LAZY LOADING
  IncomeLoaded(this.income, {this.hasMore = true});
}

// STATE TO INDICATE AN ERROR OCCURRED WHILE LOADING INCOME
class IncomeError extends IncomeState {
  final String message;
  IncomeError(this.message);
}

// STATE TO INDICATE THE INCOME OF THE LAST 7 DAYS HAVE BEEN SUCCESSFULLY LOADED
class LastSevenDayExpensesLoaded extends IncomeState {
  final Map<String, double> expensesMap;
  LastSevenDayExpensesLoaded(this.expensesMap);
}

// STATE TO INDICATE FILTERS HAVE BEEN CLEARED
class FiltersCleared extends IncomeState {}