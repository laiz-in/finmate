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
  bool _sortAscending = false;
  int _currentPage = 0;
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

void _onResetExpenses(ResetExpensesEvent event, Emitter<ExpensesState> emit) {
  _allExpenses.clear();
  _hasMore = true;
  _searchQuery = '';
  _categoryFilter = null;
  _startDateFilter = null;
  _endDateFilter = null;
  _sortAscending = false;
  add(FetchAllExpensesEvent());
}

  List<ExpensesEntity> _applyFilters() {
    var expenses = List<ExpensesEntity>.from(_allExpenses);
    
    if (_sortAscending) {
      expenses.sort((a, b) => _sortAscending
          ? a.spendingAmount.compareTo(b.spendingAmount)
          : b.spendingAmount.compareTo(a.spendingAmount));
    }

    if (_searchQuery.isNotEmpty) {
      expenses = expenses.where((expense) =>
        expense.spendingDescription.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    if (_categoryFilter != null && _categoryFilter != 'All Categories') {
      expenses = expenses.where((expense) => expense.spendingCategory == _categoryFilter).toList();
    }

    if (_startDateFilter != null && _endDateFilter != null) {
      expenses = expenses.where((expense) =>
        expense.spendingDate.isAfter(_startDateFilter!) &&
        expense.spendingDate.isBefore(_endDateFilter!.add(Duration(days: 1)))).toList();
    }

    expenses.sort((b, a) => a.spendingDate.compareTo(b.spendingDate));


    return expenses;
  }

  void _onFetchAllExpenses(FetchAllExpensesEvent event, Emitter<ExpensesState> emit) async {
    emit(ExpensesLoading());
    final result = await _totalExpensesUseCase();
    _processExpensesResult(result, emit);
  }

  void _onFetchMoreExpenses(FetchMoreExpensesEvent event, Emitter<ExpensesState> emit) async {
    if (!_hasMore) return;
    emit(ExpensesLoading(isFirstFetch: false));
    final result = await _totalExpensesUseCase();
    _processExpensesResult(result, emit, isLoadingMore: true);
  }

void _processExpensesResult(Either<String, List<ExpensesEntity>> result, Emitter<ExpensesState> emit, {bool isLoadingMore = false}) {
    result.fold(
      (error) => emit(ExpensesError(error)),
      (expenses) {
        if (!isLoadingMore) _allExpenses.clear();
        _allExpenses.addAll(expenses);
        _allExpenses.sort((b, a) => a.spendingDate.compareTo(b.spendingDate));
        _hasMore = expenses.length >= _itemsPerPage; // Only set hasMore if we received a full page
        emit(ExpensesLoaded(_applyFilters(), hasMore: _hasMore));
      },
    );
  }

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

  void _onSearchExpenses(SearchExpensesEvent event, Emitter<ExpensesState> emit) {
    _searchQuery = event.query;
    emit(ExpensesLoaded(_applyFilters(), hasMore: _hasMore));
  }

  void _onClearFilters(ClearFiltersEvent event, Emitter<ExpensesState> emit) {
    _searchQuery = '';
    _categoryFilter = null;
    _startDateFilter = null;
    _endDateFilter = null;
    _sortAscending = false;
    _allExpenses.sort((b, a) => a.spendingDate.compareTo(b.spendingDate));
    emit(ExpensesLoaded(_applyFilters(), hasMore: _hasMore));
  }

void _onSortByAmount(SortByAmountEvent event, Emitter<ExpensesState> emit) {
  _sortAscending = true;
  _sortAscending = event.ascending;
  emit(ExpensesLoaded(_applyFilters(), hasMore: _hasMore));
}

  void _onFilterByCategory(FilterByCategoryEvent event, Emitter<ExpensesState> emit) {
    _categoryFilter = event.category;
    emit(ExpensesLoaded(_applyFilters(), hasMore: _hasMore));
  }

  void _onFilterByDateRange(FilterByDateRangeEvent event, Emitter<ExpensesState> emit) {
    _startDateFilter = event.startDate;
    _endDateFilter = event.endDate;
    emit(ExpensesLoaded(_applyFilters(), hasMore: _hasMore));
  }

  void _onRefreshExpenses(RefreshExpensesEvent event, Emitter<ExpensesState> emit) async {
    emit(ExpensesLoading(isFirstFetch: false));
    final result = await _totalExpensesUseCase();
    _processExpensesResult(result, emit);
  }
}