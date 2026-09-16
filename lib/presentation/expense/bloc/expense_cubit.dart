import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/expense.dart';
import '../../../data/repositories/expense_repository.dart';
import 'expense_state.dart';

class ExpenseCubit extends Cubit<ExpenseState> {
  final ExpenseRepository _repository;
  StreamSubscription<void>? _boxSubscription;
  String? _currentUid;

  ExpenseCubit(this._repository) : super(const ExpenseState.initial()) {
    // One subscription for the cubit's entire lifetime — never
    // recreated per account switch, so there's nothing to leak or
    // fail to cancel. On any box change, re-read whichever uid is
    // currently active.
    _boxSubscription = _repository.onBoxChanged.listen((_) {
      final uid = _currentUid;
      if (uid == null) return;
      emit(ExpenseState(isLoading: false, expenses: _repository.getAllForUid(uid)));
    });
  }

  Future<void> loadExpenses(String uid) async {
    if (_currentUid != uid) {
      // Synchronous reset — no subscription to cancel, so this happens
      // instantly with no chance of a stale emission slipping through.
      emit(const ExpenseState.initial());
    }
    _currentUid = uid;

    await _repository.syncFromRemoteIfEmpty(uid);
    emit(ExpenseState(isLoading: false, expenses: _repository.getAllForUid(uid)));
  }

  Future<void> addExpense(Expense expense) async {
    await _repository.addExpense(expense);
  }

  Future<void> deleteExpense(String uid, String expenseId) async {
    await _repository.deleteExpense(uid, expenseId);
  }

  Future<void> clearOnSignOut() async {
    _currentUid = null;
    emit(const ExpenseState.initial());
  }

  @override
  Future<void> close() {
    _boxSubscription?.cancel();
    return super.close();
  }
}