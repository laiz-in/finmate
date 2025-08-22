// FILEPATH: /C:/Users/Hp/Desktop/moneyy - Copy/moneyy/lib/bloc/bills/bills_state.dart
// EXPENSES_STATE.DART
import 'package:moneyy/domain/entities/bills/bills.dart';

abstract class BillState {}

// STATE TO INDICATE BILLS ARE LOADING
class BillsLoading extends BillState {
  final bool isFirstFetch;
  BillsLoading({this.isFirstFetch = true});
}

// STATE TO INDICATE BILLS HAVE BEEN SUCCESSFULLY LOADED
class BillsLoaded extends BillState {
  final List<BillsEntity> bills;
  final bool hasMore;
  BillsLoaded(this.bills, {this.hasMore = true});
}

// STATE TO INDICATE AN ERROR OCCURRED WHILE LOADING BILLS
class BillsError extends BillState {
  final String message;
  BillsError(this.message);
}

// STATE TO INDICATE FILTERS HAVE BEEN CLEARED
class FiltersCleared extends BillState {}