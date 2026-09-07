import 'package:hive/hive.dart';

import '../models/expense.dart';
import '../services/expense_service.dart';

class ExpenseRepository {
  final ExpenseService _service;
  final Box _box = Hive.box('expensesBox');

  ExpenseRepository(this._service);

  List<Expense> _getAllForUid(String uid) {
    final expenses = _box.values
        .map((e) => Expense.fromMap(Map<String, dynamic>.from(e as Map)))
        .where((e) => e.uid == uid)
        .toList();
    expenses.sort((a, b) => b.date.compareTo(a.date));
    return expenses;
  }

  /// Live, offline-safe stream — emits the current list immediately,
  /// then again whenever the local cache changes.
  Stream<List<Expense>> watchExpenses(String uid) async* {
    yield _getAllForUid(uid);
    await for (final _ in _box.watch()) {
      yield _getAllForUid(uid);
    }
  }

  /// Used when Hive has no local cache yet (e.g. fresh login on a new device).
  /// Always resolves quickly — network failures or timeouts are caught, never
  /// left hanging, so callers (like pull-to-refresh) never get stuck.
  Future<void> syncFromRemoteIfEmpty(String uid) async {
    final hasLocalData = _getAllForUid(uid).isNotEmpty;
    if (hasLocalData) return;
    try {
      final remote = await _service.fetchAll(uid);
      for (final expense in remote) {
        await _box.put(expense.id, expense.copyWith(isSynced: true).toMap());
      }
    } catch (_) {
      // No connection, timeout, or other error — fine, just show an empty
      // list until the user is back online and adds/syncs data.
    }
  }

  Future<void> addExpense(Expense expense) async {
    await _box.put(expense.id, expense.toMap());
    _service.setExpense(expense).then((_) {
      _box.put(expense.id, expense.copyWith(isSynced: true).toMap());
    }).catchError((_) {});
  }

  Future<void> deleteExpense(String uid, String expenseId) async {
    await _box.delete(expenseId);
    _service.deleteExpense(uid, expenseId).catchError((_) {});
  }
}