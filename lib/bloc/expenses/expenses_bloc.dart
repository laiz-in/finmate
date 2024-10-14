import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moneyy/domain/entities/spending/expenses.dart';
import 'package:moneyy/domain/usecases/expenses/add_expense_usecase.dart';
import 'package:moneyy/domain/usecases/expenses/last_seven_day_expense_usecase.dart';
import 'package:moneyy/domain/usecases/expenses/last_three_expense_usecase.dart';
import 'package:moneyy/domain/usecases/expenses/total_expenses_usecase.dart';

import 'expenses_event.dart'; // Import the events
import 'expenses_state.dart'; // Import the states

// BLoC
class ExpensesBloc extends Bloc<ExpensesEvent, ExpensesState> {
  final TotalExpensesUseCase _totalExpensesUseCase;
  final LastThreeExpensesUseCase _lastThreeExpensesUseCase;
  final LastSevenDayExpensesUseCase? _lastSevenDayExpensesUseCase;
  final AddExpensesUseCase _addExpensesUseCase;

  List<ExpensesEntity> _allExpenses = []; // Store all fetched expenses
  int _currentPage = 0; // For lazy loading, we track the page number
  final int _itemsPerPage = 20; // Number of expenses to load per page
  bool _hasMore = true; // To track if more expenses are available for loading

  String _searchQuery = ''; // Store the search query for filtering

  ExpensesBloc(
    this._totalExpensesUseCase,
    this._lastThreeExpensesUseCase,
    this._lastSevenDayExpensesUseCase,
    this._addExpensesUseCase,
  ) : super(ExpensesLoading()) {
    on<FetchAllExpensesEvent>(_onFetchAllExpenses);
    on<FetchMoreExpensesEvent>(_onFetchMoreExpenses); // Lazy load more expenses
    on<AddExpenseEvent>(_onAddExpense);
    on<SearchExpensesEvent>(_onSearchExpenses); // Search functionality
    on<FetchLastSevenDayExpensesEvent>(_onFetchLastSevenDayExpenses);
  }

  void _onFetchAllExpenses(FetchAllExpensesEvent event, Emitter<ExpensesState> emit) async {
    emit(ExpensesLoading(isFirstFetch: true)); // Show initial loading state
    _currentPage = 0; // Reset the pagination
    _hasMore = true;
    _allExpenses.clear(); // Clear the list when fetching fresh data

    final Either<String, List<ExpensesEntity>> result = await _totalExpensesUseCase();
    result.fold(
      (error) => emit(ExpensesError(error)),
      (expenses) {
        if (expenses.length < _itemsPerPage) _hasMore = false; // No more items to load
        _allExpenses.addAll(expenses);
        emit(ExpensesLoaded(_filterExpenses(_allExpenses), hasMore: _hasMore));
      },
    );
  }

  void _onFetchMoreExpenses(FetchMoreExpensesEvent event, Emitter<ExpensesState> emit) async {
    if (!_hasMore) return; // No more items to load, do nothing

    emit(ExpensesLoading(isFirstFetch: false)); // Show loading at the bottom

    _currentPage++; // Increment page number
    final Either<String, List<ExpensesEntity>> result = await _totalExpensesUseCase();
    result.fold(
      (error) => emit(ExpensesError(error)),
      (expenses) {
        if (expenses.length < _itemsPerPage) _hasMore = false; // No more items to load
        _allExpenses.addAll(expenses);
        emit(ExpensesLoaded(_filterExpenses(_allExpenses), hasMore: _hasMore));
      },
    );
  }

  void _onAddExpense(AddExpenseEvent event, Emitter<ExpensesState> emit) async {
    emit(ExpensesLoading(isFirstFetch: false)); // Show loading when adding expense
    final Either result = await _addExpensesUseCase();
    result.fold(
      (error) => emit(ExpensesError(error)),
      (_) {
        // After adding an expense, refetch the data to refresh the list
        add(FetchAllExpensesEvent());
      },
    );
  }

  void _onSearchExpenses(SearchExpensesEvent event, Emitter<ExpensesState> emit) async {
    _searchQuery = event.query; // Update the search query
    emit(ExpensesLoaded(_filterExpenses(_allExpenses), hasMore: _hasMore));
  }

  void _onFetchLastSevenDayExpenses(FetchLastSevenDayExpensesEvent event, Emitter<ExpensesState> emit) async {
    emit(ExpensesLoading());
    final Either<String, Map<String, double>> result = await _lastSevenDayExpensesUseCase!();
    result.fold(
      (error) => emit(ExpensesError(error)),
      (expensesMap) => emit(LastSevenDayExpensesLoaded(expensesMap)),
    );
  }

  // Helper method to filter expenses based on search query
// Helper method to filter expenses based on search query in spendingDescription field only
List<ExpensesEntity> _filterExpenses(List<ExpensesEntity> expenses) {
  if (_searchQuery.isEmpty) {
    return expenses; // If no search query, return the full list
  } else {
    return expenses
        .where((expense) =>
            expense.spendingDescription.toLowerCase().contains(_searchQuery.toLowerCase())) // Filter by description
        .toList();
  }
}

}
