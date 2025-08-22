import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moneyy/domain/entities/expenses/expenses.dart';
import 'package:moneyy/domain/usecases/expenses/add_expense_usecase.dart';
import 'package:moneyy/domain/usecases/expenses/complete_expenses_usecase.dart';
import 'package:moneyy/domain/usecases/expenses/delete_expenses_usecase.dart';
import 'package:moneyy/domain/usecases/expenses/total_expenses_usecase.dart';
import 'package:moneyy/service_locator.dart';

import 'expenses_event.dart';
import 'expenses_state.dart';

class ExpensesBloc extends Bloc<ExpensesEvent, ExpensesState> {
  final TotalExpensesUseCase _totalExpensesUseCase;
  final AddExpensesUseCase _addExpensesUseCase;
  final CompleteExpensesUsecase _completeExpensesUseCase;
  
  List<ExpensesEntity> _allExpenses = [];
  bool _hasMore = true;
  String _searchQuery = '';
  String? _categoryFilter;
  DateTime? _startDateFilter;
  DateTime? _endDateFilter;
  bool? _sortAscending;
  int _currentPage = 1;
  static int _pageSize = 30;


  ExpensesBloc(
    this._totalExpensesUseCase,
    this._addExpensesUseCase,
    this._completeExpensesUseCase,

  ) : super(ExpensesLoading()) {
    on<FetchAllExpensesEvent>(_onFetchAllExpenses);
    on<LoadMoreExpensesEvent>(_onLoadMoreExpenses);
    on<AddExpenseEvent>(_onAddExpense);
    on<SearchExpensesEvent>(_onSearchExpenses);
    on<ClearFiltersEvent>(_onClearFilters);
    on<SortByAmountEvent>(_onSortByAmount);
    on<FilterByCategoryEvent>(_onFilterByCategory);
    on<FilterByDateRangeEvent>(_onFilterByDateRange);
    on<RefreshExpensesEvent>(_onRefreshExpenses);
    on<ResetExpensesEvent>(_onResetExpenses);
    on<DeleteExpenseEvent>(_onDeleteExpenses);
    on<FetchCompleteExpensesEvent>(_onFetchCompleteExpenses);
  }


// FETCH COMPLETE EXPENSES
Future<void> _onFetchCompleteExpenses(
  FetchCompleteExpensesEvent event,
  Emitter<ExpensesState> emit,
) async {
  emit(ExpensesLoading(isFirstFetch: true));
  try {
    final result = await _completeExpensesUseCase();
    result.fold(
      (failure) => emit(ExpensesError(failure)),
      (expenses) {
        _allExpenses = List.from(expenses);
        final hasMore = expenses.length == _pageSize;
        emit(ExpensesLoaded(_allExpenses, hasMore: hasMore));
      },
    );
  } catch (e) {
    emit(ExpensesError(e.toString()));
  }
}

// DELETING AN EXPENSE
void _onDeleteExpenses(DeleteExpenseEvent event, Emitter<ExpensesState> emit) async {
  final deleteExpensesUseCase = sl<DeleteExpensesUseCase>();
  final result = await deleteExpensesUseCase.call(uidOfTransaction: event.expenseId);

  result.fold(
    (failureMessage) {
      emit(ExpensesError(failureMessage));
    },
    (successMessage) {
      _allExpenses = _allExpenses
          .where((expense) => expense.uidOfTransaction != event.expenseId)
          .toList();
      emit(ExpensesLoaded(_applyFilters(), hasMore: _hasMore));
    },
  );
}

// RESET ALL EXPENSES
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

// APPLYING DIFFERENT FILTERS
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
        0, 0, 0, 0,
      );
      DateTime endDateWithTime = DateTime(
        _endDateFilter!.year,
        _endDateFilter!.month,
        _endDateFilter!.day,
        23, 59, 59, 999,
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
    expenses.sort((b, a) => a.spendingDate.compareTo(b.spendingDate));
  }
    return expenses;
  }

// TO FETCH ALL EXPENSES
Future<void> _onFetchAllExpenses(
  FetchAllExpensesEvent event,
  Emitter<ExpensesState> emit,
) async {
  emit(ExpensesLoading(isFirstFetch: true));
  try {
    _currentPage = 1;
    _pageSize = 30;
    final result = await _totalExpensesUseCase(page: _currentPage, pageSize: _pageSize);
    result.fold(
      (failure) => emit(ExpensesError(failure)),
      (expenses) {
        _allExpenses = List.from(expenses);
        final hasMore = expenses.length == _pageSize;
        emit(ExpensesLoaded(_allExpenses, hasMore: hasMore));
      },
    );
  } catch (e) {
    emit(ExpensesError(e.toString()));
  }
}

// LOAD MORE EXPENSES
Future<void> _onLoadMoreExpenses(
  LoadMoreExpensesEvent event,
  Emitter<ExpensesState> emit,
) async {
  try {
    emit(ExpensesLoading(isFirstFetch: false));
    _currentPage++;
    _pageSize += 30;


    final result = await _totalExpensesUseCase(page: _currentPage, pageSize: _pageSize);
    result.fold(
      (failure) => emit(ExpensesError(failure)),
      (expenses) {
        _allExpenses = List.from(expenses);
        final hasMore = expenses.length == _pageSize;
        emit(ExpensesLoaded(_allExpenses, hasMore: hasMore));
      },
    );
  } catch (e) {
    _currentPage--;
    emit(ExpensesError(e.toString()));
  }
}

// ADD NEW EXPENSE
Future<void> _onAddExpense(AddExpenseEvent event, Emitter<ExpensesState> emit) async {
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

// SEARCH FOR NEW EXPENSE
void _onSearchExpenses(SearchExpensesEvent event, Emitter<ExpensesState> emit) {
    _searchQuery = event.query;
    emit(ExpensesLoaded(_applyFilters(), hasMore: _hasMore));
  }

// CLEAR FILTER
void _onClearFilters(ClearFiltersEvent event, Emitter<ExpensesState> emit) {
    _searchQuery = '';
    _categoryFilter = null;
    _startDateFilter = null;
    _endDateFilter = null;
    _sortAscending = null;
    _allExpenses.sort((b, a) => a.spendingDate.compareTo(b.spendingDate));
    emit(ExpensesLoaded(_applyFilters(), hasMore: _hasMore));
  }

// SORT BY AMOUNT
void _onSortByAmount(SortByAmountEvent event, Emitter<ExpensesState> emit) {
    _sortAscending = event.ascending;
    emit(ExpensesLoaded(_applyFilters(), hasMore: _hasMore));
  }

// FILTER BY CATEGORY
void _onFilterByCategory(FilterByCategoryEvent event, Emitter<ExpensesState> emit) {
    _categoryFilter = event.category;
    emit(ExpensesLoaded(_applyFilters(), hasMore: _hasMore));
  }

// FILTER BY DATE RANGE
void _onFilterByDateRange(FilterByDateRangeEvent event, Emitter<ExpensesState> emit) {
    _startDateFilter = event.startDate;
    _endDateFilter = event.endDate;
    emit(ExpensesLoaded(_applyFilters(), hasMore: _hasMore));
  }

// REFRESH EXPENSES
void _onRefreshExpenses(RefreshExpensesEvent event, Emitter<ExpensesState> emit) async {
  emit(ExpensesLoading(isFirstFetch: true));
    try {
      _currentPage = 1;
      final result = await _totalExpensesUseCase(page: _currentPage, pageSize: _pageSize);
      result.fold(
        (failure) => emit(ExpensesError(failure)),
        (expenses) {
          _allExpenses = expenses;
          final hasMore = expenses.length == _pageSize;
          emit(ExpensesLoaded(_allExpenses, hasMore: hasMore));
        }
      );
    } catch (e) {
      emit(ExpensesError(e.toString()));
    }
}

}
