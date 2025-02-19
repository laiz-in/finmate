import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moneyy/domain/entities/income/income.dart';
import 'package:moneyy/domain/usecases/income/add_income_usecase.dart';
import 'package:moneyy/domain/usecases/income/complete_income_usecase.dart';
import 'package:moneyy/domain/usecases/income/delete_income_usecase.dart';
import 'package:moneyy/domain/usecases/income/total_income_usecase.dart';
import 'package:moneyy/service_locator.dart';

import 'income_event.dart';
import 'income_state.dart';

class IncomeBloc extends Bloc<IncomeEvent, IncomeState> {
  final TotalIncomeUseCase _totalIncomeUseCase;
  final AddIncomeUseCase _addIncomeUseCase;
  final CompleteIncomeUseCase _completeIncomeUseCase;
  List<IncomeEntity> _allIncome = [];
  bool _hasMore = true;
  String _searchQuery = '';
  String? _categoryFilter;
  DateTime? _startDateFilter;
  DateTime? _endDateFilter;
  bool? _sortAscending;
  int _currentPage = 1;
  static int _pageSize = 30;


  IncomeBloc(
    this._totalIncomeUseCase,
    this._addIncomeUseCase,
    this._completeIncomeUseCase
  ) : super(IncomeLoading()) {
    on<FetchAllIncomeEvent>(_onFetchAllIncome);
    on<FetchCompleteIncomeEvent>(_onFetchCompleteIncome);
    on<LoadMoreIncomeEvent>(_onLoadMoreIncome);
    on<AddIncomeEvent>(_onAddIncome);
    on<SearchIncomeEvent>(_onSearchIncome);
    on<ClearFiltersEvent>(_onClearFilters);
    on<SortByAmountEvent>(_onSortByAmount);
    on<FilterByCategoryEvent>(_onFilterByCategory);
    on<FilterByDateRangeEvent>(_onFilterByDateRange);
    on<RefreshIncomeEvent>(_onRefreshIncome);
    on<ResetIncomeEvent>(_onResetIncome);
    on<DeleteIncomeEvent>(_onDeleteIncome);
  }

// DELETING AN INCOME
void _onDeleteIncome(DeleteIncomeEvent event, Emitter<IncomeState> emit) async {
  final deleteIncomeUseCase = sl<DeleteIncomeUseCase>();
  final result = await deleteIncomeUseCase.call(uidOfIncome: event.incomeId);

  result.fold(
    (failureMessage) {
      emit(IncomeError(failureMessage));
    },
    (successMessage) {
      // Remove the deleted expense locally from _allExpenses
      _allIncome = _allIncome
          .where((income) => income.uidOfIncome != event.incomeId)
          .toList();

      // Re-apply filters and emit the updated list without showing the loading indicator
      emit(IncomeLoaded(_applyFilters(), hasMore: _hasMore));
    },
  );
}

// RESET ALL INCOME
void _onResetIncome(ResetIncomeEvent event, Emitter<IncomeState> emit) {
    _allIncome.clear();
    _hasMore = true;
    _searchQuery = '';
    _categoryFilter = null;
    _startDateFilter = null;
    _endDateFilter = null;
    _sortAscending = null;
    add(FetchAllIncomeEvent());
  }

// APPLYING DIFFERENT FILTERS
List<IncomeEntity> _applyFilters() {
    var income = List<IncomeEntity>.from(_allIncome);

    if (_categoryFilter != null && _categoryFilter != 'All Categories') {
      income = income.where((income) => income.incomeCategory == _categoryFilter).toList();
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

      income = income.where((income) =>
          income.incomeDate.isAfter(startDateWithTime) && income.incomeDate.isBefore(endDateWithTime)).toList();
    }

    if (_searchQuery.isNotEmpty) {
      income = income.where((income) =>
          income.incomeRemarks.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

  if (_sortAscending == true) {
    income.sort((a, b) => a.incomeAmount.compareTo(b.incomeAmount));
  } else if (_sortAscending == false) {
    income.sort((a, b) => b.incomeAmount.compareTo(a.incomeAmount));
  } else {
    // Default sorting by date if no other sort is applied
    income.sort((b, a) => a.incomeDate.compareTo(b.incomeDate));
  }

    return income;
  }

// TO FETCH ALL INCOME (Initial Load - 30 items)
Future<void> _onFetchAllIncome(
  FetchAllIncomeEvent event,
  Emitter<IncomeState> emit,
) async {
  emit(IncomeLoading(isFirstFetch: true));
  try {
    _currentPage = 1; // Reset to the first page
    _pageSize = 30;  // Set page size to 30 initially
    final result = await _totalIncomeUseCase(page: _currentPage, pageSize: _pageSize);
    result.fold(
      (failure) => emit(IncomeError(failure)), // Emit error on failure
      (income) {
        _allIncome = List.from(income); // Replace with the new data
        final hasMore = income.length == _pageSize;
        emit(IncomeLoaded(_allIncome, hasMore: hasMore));
      },
    );
  } catch (e) {
    emit(IncomeError(e.toString())); // Emit error if an exception occurs
  }
}


// TO FETCH ALL INCOME (Initial Load - 30 items)
Future<void> _onFetchCompleteIncome(
  FetchCompleteIncomeEvent event,
  Emitter<IncomeState> emit,
) async {
  emit(IncomeLoading(isFirstFetch: true));
  try {
    final result = await _completeIncomeUseCase();
    result.fold(
      (failure) => emit(IncomeError(failure)), // Emit error on failure
      (income) {
        _allIncome = List.from(income); // Replace with the new data
        final hasMore = income.length == _pageSize;
        emit(IncomeLoaded(_allIncome, hasMore: hasMore));
      },
    );
  } catch (e) {
    emit(IncomeError(e.toString())); // Emit error if an exception occurs
  }
}

// LOAD MORE EXPENSES (Add 30 more items on each click)
Future<void> _onLoadMoreIncome(
  LoadMoreIncomeEvent event,
  Emitter<IncomeState> emit,
) async {
  try {
    emit(IncomeLoading(isFirstFetch: false)); // Emit loading for "load more"
    _currentPage++; // Increment page for the next fetch
    _pageSize += 30; // Increase page size by 30 for subsequent loads


    final result = await _totalIncomeUseCase(page: _currentPage, pageSize: _pageSize);
    result.fold(
      (failure) => emit(IncomeError(failure)), // Emit error on failure
      (income) {
        _allIncome = List.from(income); // Replace with the new data
        final hasMore = income.length == _pageSize;
        emit(IncomeLoaded(_allIncome, hasMore: hasMore));
      },
    );
  } catch (e) {
    _currentPage--; // Revert page increment if an exception occurs
    emit(IncomeError(e.toString()));
  }
}

// Add a new expense
Future<void> _onAddIncome(AddIncomeEvent event, Emitter<IncomeState> emit) async {
    emit(IncomeLoading(isFirstFetch: false));
    final result = await _addIncomeUseCase();
    result.fold(
      (error) => emit(IncomeError(error)),
      (newIncome) {
        _allIncome.insert(0, newIncome);
        emit(IncomeLoaded(_applyFilters(), hasMore: _hasMore));
      },
    );
  }

// Search for expenses
void _onSearchIncome(SearchIncomeEvent event, Emitter<IncomeState> emit) {
    _searchQuery = event.query;
    emit(IncomeLoaded(_applyFilters(), hasMore: _hasMore));
  }

// Clear filters
void _onClearFilters(ClearFiltersEvent event, Emitter<IncomeState> emit) {
    _searchQuery = '';
    _categoryFilter = null;
    _startDateFilter = null;
    _endDateFilter = null;
    _sortAscending = null;
    _allIncome.sort((b, a) => a.incomeDate.compareTo(b.incomeDate));
    emit(IncomeLoaded(_applyFilters(), hasMore: _hasMore));
  }

// Sort by amount
void _onSortByAmount(SortByAmountEvent event, Emitter<IncomeState> emit) {
    _sortAscending = event.ascending;
    emit(IncomeLoaded(_applyFilters(), hasMore: _hasMore));
  }

// Filter by category
void _onFilterByCategory(FilterByCategoryEvent event, Emitter<IncomeState> emit) {
    _categoryFilter = event.category;
    emit(IncomeLoaded(_applyFilters(), hasMore: _hasMore));
  }

// Filter by date range
void _onFilterByDateRange(FilterByDateRangeEvent event, Emitter<IncomeState> emit) {
    _startDateFilter = event.startDate;
    _endDateFilter = event.endDate;
    emit(IncomeLoaded(_applyFilters(), hasMore: _hasMore));
  }

// Refresh expenses
void _onRefreshIncome(RefreshIncomeEvent event, Emitter<IncomeState> emit) async {
  emit(IncomeLoading(isFirstFetch: true));
    try {
      _currentPage = 1;
      final result = await _totalIncomeUseCase(page: _currentPage, pageSize: _pageSize);
      result.fold(
        (failure) => emit(IncomeError(failure)),
        (income) {
          _allIncome = income;
          final hasMore = income.length == _pageSize;
          emit(IncomeLoaded(_allIncome, hasMore: hasMore));
        }
      );
    } catch (e) {
      emit(IncomeError(e.toString()));
    }
}

}
