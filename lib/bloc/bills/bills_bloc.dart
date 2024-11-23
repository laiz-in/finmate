import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moneyy/domain/entities/bills/bills.dart';
import 'package:moneyy/domain/usecases/bills/add_bill_usecase.dart';
import 'package:moneyy/domain/usecases/bills/delete_bill_usecase.dart';
import 'package:moneyy/domain/usecases/bills/total_bills_usecase.dart';
import 'package:moneyy/service_locator.dart';

import 'bills_event.dart';
import 'bills_state.dart';

class BillsBloc extends Bloc<BillsEvent, BillState> {
  final TotalBillsUsecase _totalBillsUseCase;
  final AddBillUsecase _addBillsUseCase;
  List<BillsEntity> _allBills = [];
  bool _hasMore = true;
  String _searchQuery = '';
  bool? _sortByBillAmount;
  bool? _sortAscendingByDueDate;
  int _currentPage = 1;
  static int _pageSize = 30;


  BillsBloc(
    this._totalBillsUseCase,
    this._addBillsUseCase,
  ) : super(BillsLoading()) {
    on<FetchAllBillsEvent>(_onFetchAllBills);
    on<LoadMoreBillsEvent>(_onLoadMoreBills);
    on<AddBillEvent>(_onAddBills);
    on<SearchBillsEvent>(_onSearchBills);
    on<ClearFiltersEvent>(_onClearFilters);
    on<RefreshBillsEvent>(_onRefreshBills);
    on<SortByBillAmount>(_onSortByBillAmount);
    on<SortByDueDate>(_onSortByDueDate);
    on<ResetBillsEvent>(_onResetBills);
    on<DeleteBillsEvent>(_onDeleteBills);
  }

// DELETING AN EXPENSE
void _onDeleteBills(DeleteBillsEvent event, Emitter<BillState> emit) async {
  final deleteBillsUseCase = sl<DeleteBillUsecase>();
  final result = await deleteBillsUseCase.call(uidOfBill: event.billId);

  result.fold(
    (failureMessage) {
      emit(BillsError(failureMessage));
    },
    (successMessage) {
      // Remove the deleted bill locally from _allExpenses
      _allBills = _allBills
          .where((bills) => bills.uidOfBill != event.billId)
          .toList();
      // Re-apply filters and emit the updated list without showing the loading indicator
      emit(BillsLoaded(_applyFilters(), hasMore: _hasMore));
    },
  );
}

// RESET ALL EXPENSES
void _onResetBills(ResetBillsEvent event, Emitter<BillState> emit) {
    _allBills.clear();
    _hasMore = true;
    _searchQuery = '';
    _sortAscendingByDueDate = null;
    _sortByBillAmount = null;
    add(FetchAllBillsEvent());
  }

// APPLYING DIFFERENT FILTERS
List<BillsEntity> _applyFilters() {
    var bills = List<BillsEntity>.from(_allBills);
    

    if (_searchQuery.isNotEmpty) {
      bills = bills.where((bills) =>
          bills.billTitle.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    if (_sortByBillAmount == true){
          bills.sort((a, b) => a.billAmount.compareTo(b.billAmount));
    } else if (_sortByBillAmount == false){
          bills.sort((a, b) => b.billAmount.compareTo(a.billAmount));
    }else if (_sortAscendingByDueDate == true) {
      bills.sort((a, b) => a.billDueDate.compareTo(b.billDueDate));
    } else if (_sortAscendingByDueDate == false) {
      bills.sort((a, b) => b.billDueDate.compareTo(a.billDueDate));
    } else {
      // Default sorting by date if no other sort is applied
      bills.sort((b, a) => a.addedDate.compareTo(b.addedDate));
    }

    return bills;
  }

// TO FETCH ALL EXPENSES (Initial Load - 30 items)
Future<void> _onFetchAllBills(
  FetchAllBillsEvent event,
  Emitter<BillState> emit,
) async {
  emit(BillsLoading(isFirstFetch: true));
  try {
    _currentPage = 1; // Reset to the first page
    _pageSize = 30;  // Set page size to 30 initially
    final result = await _totalBillsUseCase(page: _currentPage, pageSize: _pageSize);
    result.fold(
      (failure) => emit(BillsError(failure)), // Emit error on failure
      (bills) {
        _allBills = List.from(bills); // Replace with the new data
        final hasMore = bills.length == _pageSize;
        emit(BillsLoaded(_allBills, hasMore: hasMore));
      },
    );
  } catch (e) {
    emit(BillsError(e.toString())); // Emit error if an exception occurs
  }
}

// LOAD MORE EXPENSES (Add 30 more items on each click)
Future<void> _onLoadMoreBills(
  LoadMoreBillsEvent event,
  Emitter<BillState> emit,
) async {
  try {
    emit(BillsLoading(isFirstFetch: false)); // Emit loading for "load more"
    _currentPage++; // Increment page for the next fetch
    _pageSize += 30; // Increase page size by 30 for subsequent loads


    final result = await _totalBillsUseCase(page: _currentPage, pageSize: _pageSize);
    result.fold(
      (failure) => emit(BillsError(failure)), // Emit error on failure
      (bills) {
        _allBills = List.from(bills); // Replace with the new data
        final hasMore = bills.length == _pageSize;
        emit(BillsLoaded(_allBills, hasMore: hasMore));
      },
    );
  } catch (e) {
    _currentPage--; // Revert page increment if an exception occurs
    emit(BillsError(e.toString()));
  }
}

// Add a new expense
Future<void> _onAddBills(AddBillEvent event, Emitter<BillState> emit) async {
    emit(BillsLoading(isFirstFetch: false));
    final result = await _addBillsUseCase();
    result.fold(
      (error) => emit(BillsError(error)),
      (newBill) {
        _allBills.insert(0, newBill);
        emit(BillsLoaded(_applyFilters(), hasMore: _hasMore));
      },
    );
  }

// Search for expenses
void _onSearchBills(SearchBillsEvent event, Emitter<BillState> emit) {
    _searchQuery = event.query;
    emit(BillsLoaded(_applyFilters(), hasMore: _hasMore));
  }

// Clear filters
void _onClearFilters(ClearFiltersEvent event, Emitter<BillState> emit) {
    _searchQuery = '';
    _sortAscendingByDueDate = null;
    _sortByBillAmount =null;
    _allBills.sort((b, a) => a.addedDate.compareTo(b.addedDate));
    emit(BillsLoaded(_applyFilters(), hasMore: _hasMore));
  }

// Sort by amount
void _onSortByBillAmount(SortByBillAmount event, Emitter<BillState> emit) {
    _sortByBillAmount = event.ascending;
    emit(BillsLoaded(_applyFilters(), hasMore: _hasMore));
  }

// Sort by due date
void _onSortByDueDate(SortByDueDate event, Emitter<BillState> emit) {
    _sortAscendingByDueDate = event.ascending;
    emit(BillsLoaded(_applyFilters(), hasMore: _hasMore));
  }


// Refresh expenses
void _onRefreshBills(RefreshBillsEvent event, Emitter<BillState> emit) async {
  emit(BillsLoading(isFirstFetch: true));
    try {
      _currentPage = 1;
      final result = await _totalBillsUseCase(page: _currentPage, pageSize: _pageSize);
      result.fold(
        (failure) => emit(BillsError(failure)),
        (bills) {
          _allBills = bills;
          final hasMore = bills.length == _pageSize;
          emit(BillsLoaded(_allBills, hasMore: hasMore));
        }
      );
    } catch (e) {
      emit(BillsError(e.toString()));
    }
}

}
