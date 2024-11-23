// expenses_state.dart
import 'package:moneyy/domain/entities/bills/bills.dart';

abstract class BillState {}

// State to indicate bills are loading
class BillsLoading extends BillState {
  final bool isFirstFetch;
  BillsLoading({this.isFirstFetch = true});
}

// State to indicate bills have been successfully loaded
class BillsLoaded extends BillState {
  final List<BillsEntity> bills;
  final bool hasMore; // Indicates if more expenses are available for lazy loading
  BillsLoaded(this.bills, {this.hasMore = true});
}

// State to indicate an error occurred while loading bills
class BillsError extends BillState {
  final String message;
  BillsError(this.message);
}


// State to indicate filters have been cleared
class FiltersCleared extends BillState {}
