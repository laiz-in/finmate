import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moneyy/domain/entities/bills/bills.dart';
import 'package:moneyy/domain/usecases/bills/add_bill_usecase.dart';
import 'package:moneyy/domain/usecases/bills/change_paid_status_usecase.dart';
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
  bool? _filterByPaidStatus; // Added filter by paid status
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
    on<FilterByPaidStatusEvent>(_onFilterByPaidStatus); // Added event for paid status filter
    on<ResetBillsEvent>(_onResetBills);
    on<DeleteBillsEvent>(_onDeleteBills);
    on<UpdateBillStatusEvent>(_onUpdateBillStatus);
  }

  // UPDATING BILL STATUS
  void _onUpdateBillStatus(UpdateBillStatusEvent event, Emitter<BillState> emit) async {
    final updatePaidStatusUseCase = sl<UpdatePaidStatusUsecase>();
    final result = await updatePaidStatusUseCase.call(uidOfBill: event.billId);

    result.fold(
      (failureMessage) {
        emit(BillsError(failureMessage));
      },
      (successMessage) {
        add(FetchAllBillsEvent());
      },
    );
  }



  // DELETING A BILL
  void _onDeleteBills(DeleteBillsEvent event, Emitter<BillState> emit) async {
    final deleteBillsUseCase = sl<DeleteBillUsecase>();
    final result = await deleteBillsUseCase.call(uidOfBill: event.billId);

    result.fold(
      (failureMessage) {
        emit(BillsError(failureMessage));
      },
      (successMessage) {
        _allBills = _allBills
            .where((bills) => bills.uidOfBill != event.billId)
            .toList();
        emit(BillsLoaded(_applyFilters(), hasMore: _hasMore));
      },
    );
  }

  // RESET ALL BILLS
  void _onResetBills(ResetBillsEvent event, Emitter<BillState> emit) {
    _allBills.clear();
    _hasMore = true;
    _searchQuery = '';
    _sortAscendingByDueDate = null;
    _sortByBillAmount = null;
    _filterByPaidStatus = null;
    add(FetchAllBillsEvent());
  }

  // APPLYING DIFFERENT FILTERS
  List<BillsEntity> _applyFilters() {
    var bills = List<BillsEntity>.from(_allBills);

  if (_searchQuery.isNotEmpty) {
    bills = bills.where((bill) {
      final titleMatch = bill.billTitle.toLowerCase().contains(_searchQuery.toLowerCase());
      final descriptionMatch = bill.billDescription.toLowerCase().contains(_searchQuery.toLowerCase());
      return titleMatch || descriptionMatch; // Match either title or description
    }).toList();
  }

    if (_sortByBillAmount == true) {
      bills.sort((a, b) => a.billAmount.compareTo(b.billAmount));
    } else if (_sortByBillAmount == false) {
      bills.sort((a, b) => b.billAmount.compareTo(a.billAmount));
    } else if (_sortAscendingByDueDate == true) {
      bills.sort((a, b) => a.billDueDate.compareTo(b.billDueDate));
    } else if (_sortAscendingByDueDate == false) {
      bills.sort((a, b) => b.billDueDate.compareTo(a.billDueDate));
    } else {
      bills.sort((b, a) => a.addedDate.compareTo(b.addedDate));
    }

    if (_filterByPaidStatus != null) {
      bills = bills.where((bill) => bill.paidStatus == (_filterByPaidStatus! ? 1 : 0)).toList();
    }

    return bills;
  }
  // TO FETCH ALL BILLS (Initial Load - 30 items)
  Future<void> _onFetchAllBills(
    FetchAllBillsEvent event,
    Emitter<BillState> emit,
  ) async {
    emit(BillsLoading(isFirstFetch: true));
    try {
      _currentPage = 1; // Reset to the first page
      _pageSize = 30; // Set page size to 30 initially
      final result =
          await _totalBillsUseCase(page: _currentPage, pageSize: _pageSize);
      result.fold(
        (failure) => emit(BillsError(failure)),
        (bills) {
          _allBills = List.from(bills);
          final hasMore = bills.length == _pageSize;
          emit(BillsLoaded(_allBills, hasMore: hasMore));
        },
      );
    } catch (e) {
      emit(BillsError(e.toString()));
    }
  }

  // LOAD MORE BILLS (Add 30 more items on each click)
  Future<void> _onLoadMoreBills(
    LoadMoreBillsEvent event,
    Emitter<BillState> emit,
  ) async {
    try {
      emit(BillsLoading(isFirstFetch: false));
      _currentPage++;
      _pageSize += 30;

      final result =
          await _totalBillsUseCase(page: _currentPage, pageSize: _pageSize);
      result.fold(
        (failure) => emit(BillsError(failure)),
        (bills) {
          _allBills = List.from(bills);
          final hasMore = bills.length == _pageSize;
          emit(BillsLoaded(_allBills, hasMore: hasMore));
        },
      );
    } catch (e) {
      _currentPage--;
      emit(BillsError(e.toString()));
    }
  }

  // Add a new bill
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

  // Search for bills
  void _onSearchBills(SearchBillsEvent event, Emitter<BillState> emit) {
    _searchQuery = event.query;
    emit(BillsLoaded(_applyFilters(), hasMore: _hasMore));
  }

  // Clear filters
  void _onClearFilters(ClearFiltersEvent event, Emitter<BillState> emit) {
    _searchQuery = '';
    _sortAscendingByDueDate = null;
    _sortByBillAmount = null;
    _filterByPaidStatus = null;
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

  // Filter by paid status
  void _onFilterByPaidStatus(
    FilterByPaidStatusEvent event, Emitter<BillState> emit) {
  _filterByPaidStatus = event.paidStatus == 1; // true if 1, false otherwise
  emit(BillsLoaded(_applyFilters(), hasMore: _hasMore));
}

  // Refresh bills
  void _onRefreshBills(RefreshBillsEvent event, Emitter<BillState> emit) async {
    emit(BillsLoading(isFirstFetch: true));
    try {
      _currentPage = 1;
      final result =
      await _totalBillsUseCase(page: _currentPage, pageSize: _pageSize);
      result.fold(
        (failure) => emit(BillsError(failure)),
        (bills) {
          _allBills = bills;
          final hasMore = bills.length == _pageSize;
          emit(BillsLoaded(_allBills, hasMore: hasMore));
        },
      );
    } catch (e) {
      emit(BillsError(e.toString()));
    }
  }
}
