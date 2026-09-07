import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/expense.dart';
import '../../../data/repositories/expense_repository.dart';
import 'expense_state.dart';

class ExpenseCubit extends Cubit<ExpenseState> {
  final ExpenseRepository _repository;
  StreamSubscription<List<Expense>>? _subscription;

  ExpenseCubit(this._repository) : super(const ExpenseState.initial());

  Future<void> loadExpenses(String uid) async {
    await _repository.syncFromRemoteIfEmpty(uid);
    await _subscription?.cancel();
    _subscription = _repository.watchExpenses(uid).listen((expenses) {
      emit(ExpenseState(isLoading: false, expenses: expenses));
    });
  }

  Future<void> addExpense(Expense expense) async {
    await _repository.addExpense(expense);
    // No manual emit needed — the Hive watch stream picks up the change automatically.
  }

  Future<void> deleteExpense(String uid, String expenseId) async {
    await _repository.deleteExpense(uid, expenseId);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}