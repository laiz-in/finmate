import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moneyy/domain/entities/spending/expenses.dart';
import 'package:moneyy/domain/usecases/expenses/add_expense_usecase.dart';
import 'package:moneyy/domain/usecases/expenses/total_expenses_usecase.dart';

import 'expenses_event.dart';
import 'expenses_state.dart';

class ExpensesBloc extends Bloc<ExpensesEvent, ExpensesState> {
  final TotalExpensesUseCase _totalExpensesUseCase;
  final AddExpensesUseCase _addExpensesUseCase;

  List<ExpensesEntity> _allExpenses = [];
  bool _hasMore = true;
  String _searchQuery = '';
  String? _categoryFilter;
  DateTime? _startDateFilter;
  DateTime? _endDateFilter;
  bool? _sortAscending;
  // int _currentPage = 0;
  static const int _itemsPerPage = 20;

  ExpensesBloc(
    this._totalExpensesUseCase,
    this._addExpensesUseCase,
  ) : super(ExpensesLoading()) {
    on<FetchAllExpensesEvent>(_onFetchAllExpenses);
    on<FetchMoreExpensesEvent>(_onFetchMoreExpenses);
    on<AddExpenseEvent>(_onAddExpense);
    on<SearchExpensesEvent>(_onSearchExpenses);
    on<ClearFiltersEvent>(_onClearFilters);
    on<SortByAmountEvent>(_onSortByAmount);
    on<FilterByCategoryEvent>(_onFilterByCategory);
    on<FilterByDateRangeEvent>(_onFilterByDateRange);
    on<RefreshExpensesEvent>(_onRefreshExpenses);
    on<ResetExpensesEvent>(_onResetExpenses);
  }

  // Reset all expenses
  void _onResetExpenses(ResetExpensesEvent event, Emitter<ExpensesState> emit) {
    _allExpenses.clear();
    _hasMore = true;
    _searchQuery = '';
    _categoryFilter = null;
    _startDateFilter = null;
    _endDateFilter = null;
    _sortAscending = null;
    add(FetchAllExpensesEvent());
  }



  // Apply filters and sort by amount
  List<ExpensesEntity> _applyFilters() {
    var expenses = List<ExpensesEntity>.from(_allExpenses);

    if (_categoryFilter != null && _categoryFilter != 'All Categories') {
      expenses = expenses.where((expense) => expense.spendingCategory == _categoryFilter).toList();
    }

    if (_startDateFilter != null && _endDateFilter != null) {
      DateTime startDateWithTime = DateTime(
        _startDateFilter!.year,
        _startDateFilter!.month,
        _startDateFilter!.day,
        0, 0, 0, 0, // Explicitly set to 12 AM
      );
      DateTime endDateWithTime = DateTime(
        _endDateFilter!.year,
        _endDateFilter!.month,
        _endDateFilter!.day,
        23, 59, 59, 999, // Explicitly set to 11:59:59.999 PM
      );

      expenses = expenses.where((expense) =>
          expense.spendingDate.isAfter(startDateWithTime) && expense.spendingDate.isBefore(endDateWithTime)).toList();
    }

    if (_searchQuery.isNotEmpty) {
      expenses = expenses.where((expense) =>
          expense.spendingDescription.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

  if (_sortAscending == true) {
    expenses.sort((a, b) => a.spendingAmount.compareTo(b.spendingAmount));
  } else if (_sortAscending == false) {
    expenses.sort((a, b) => b.spendingAmount.compareTo(a.spendingAmount));
  } else {
    // Default sorting by date if no other sort is applied
    expenses.sort((b, a) => a.spendingDate.compareTo(b.spendingDate));
  }

    return expenses;
  }




  // Fetch all expenses
  void _onFetchAllExpenses(FetchAllExpensesEvent event, Emitter<ExpensesState> emit) async {
    emit(ExpensesLoading());
    final result = await _totalExpensesUseCase();
    _processExpensesResult(result, emit);
  }

  // Load more expenses
  void _onFetchMoreExpenses(FetchMoreExpensesEvent event, Emitter<ExpensesState> emit) async {
    if (!_hasMore) return;
    emit(ExpensesLoading(isFirstFetch: false));
    final result = await _totalExpensesUseCase();
    _processExpensesResult(result, emit, isLoadingMore: true);
  }

  // Process fetched expenses result
  void _processExpensesResult(Either<String, List<ExpensesEntity>> result, Emitter<ExpensesState> emit, {bool isLoadingMore = false}) {
    result.fold(
      (error) => emit(ExpensesError(error)),
      (expenses) {
        if (!isLoadingMore) _allExpenses.clear();
        _allExpenses.addAll(expenses);
        _hasMore = expenses.length >= _itemsPerPage;
        emit(ExpensesLoaded(_applyFilters(), hasMore: _hasMore));
      },
    );
  }

  // Add a new expense
  void _onAddExpense(AddExpenseEvent event, Emitter<ExpensesState> emit) async {
    emit(ExpensesLoading(isFirstFetch: false));
    final result = await _addExpensesUseCase();
    result.fold(
      (error) => emit(ExpensesError(error)),
      (newExpense) {
        _allExpenses.insert(0, newExpense);
        emit(ExpensesLoaded(_applyFilters(), hasMore: _hasMore));
      },
    );
  }

  // Search for expenses
  void _onSearchExpenses(SearchExpensesEvent event, Emitter<ExpensesState> emit) {
    _searchQuery = event.query;
    emit(ExpensesLoaded(_applyFilters(), hasMore: _hasMore));
  }

  // Clear filters
  void _onClearFilters(ClearFiltersEvent event, Emitter<ExpensesState> emit) {
    _searchQuery = '';
    _categoryFilter = null;
    _startDateFilter = null;
    _endDateFilter = null;
    _sortAscending = null;
    _allExpenses.sort((b, a) => a.spendingDate.compareTo(b.spendingDate));
    emit(ExpensesLoaded(_applyFilters(), hasMore: _hasMore));
  }

  // Sort by amount
  void _onSortByAmount(SortByAmountEvent event, Emitter<ExpensesState> emit) {

    _sortAscending = event.ascending;

    emit(ExpensesLoaded(_applyFilters(), hasMore: _hasMore));
  }

  // Filter by category
  void _onFilterByCategory(FilterByCategoryEvent event, Emitter<ExpensesState> emit) {
    _categoryFilter = event.category;
    emit(ExpensesLoaded(_applyFilters(), hasMore: _hasMore));
  }

  // Filter by date range
  void _onFilterByDateRange(FilterByDateRangeEvent event, Emitter<ExpensesState> emit) {
    _startDateFilter = event.startDate;
    _endDateFilter = event.endDate;
    emit(ExpensesLoaded(_applyFilters(), hasMore: _hasMore));
  }

  // Refresh expenses
  void _onRefreshExpenses(RefreshExpensesEvent event, Emitter<ExpensesState> emit) async {
    emit(ExpensesLoading(isFirstFetch: false));
    final result = await _totalExpensesUseCase();
    _processExpensesResult(result, emit);
  }
}
