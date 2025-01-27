// expenses_event.dart

import 'package:moneyy/domain/entities/bills/bills.dart';

abstract class BillsEvent {}

// TOTAL 8 EVENTS



class FilterByPaidStatusEvent extends BillsEvent {
  final int paidStatus; // 1 for Paid, 0 for Pending
  FilterByPaidStatusEvent({required this.paidStatus});
}
// TO FETCH ALL BILLS
class FetchAllBillsEvent extends BillsEvent {}

// TO LAOD MORE BILLS ON
class LoadMoreBillsEvent extends BillsEvent {}

// WHEN ADDING A NEW BILL
class AddBillEvent extends BillsEvent {
  final BillsEntity bills;
  AddBillEvent(this.bills);
}

// WHEN DELETING A BILL
class DeleteBillsEvent extends BillsEvent {
  final String billId;
  DeleteBillsEvent(this.billId);
}

// WHEN UPDATING A BILL STATUS
class UpdateBillStatusEvent extends BillsEvent {
  final String billId;
  UpdateBillStatusEvent(this.billId);
}

// WHEN SEARCHING A BILL
class SearchBillsEvent extends BillsEvent {
  final String query;
  SearchBillsEvent(this.query);
}

// TO SEARCH BILL  BY DUE DATE
class SortByDueDate extends BillsEvent {
  final bool ascending;
  SortByDueDate(this.ascending);
}

// SORT BY BILL AMOUNT
class SortByBillAmount extends BillsEvent {
  final bool ascending;
  SortByBillAmount(this.ascending);
}

// RESET THE BILL LIST
class ResetBillsEvent extends BillsEvent {
  final int currentPage=1;
  final int pageSize=30;
}

// CLEAR ANY FILTERS
class ClearFiltersEvent extends BillsEvent {}

// REFRESH THE BILL LIST
class RefreshBillsEvent extends BillsEvent {}