import 'package:hive/hive.dart';

import '../models/expense.dart';
import '../services/expense_service.dart';

class ExpenseRepository {
  final ExpenseService _service;
  final Box _box = Hive.box('expensesBox');

  ExpenseRepository(this._service);

  String _keyFor(String uid, String expenseId) => '${uid}_$expenseId';

  /// Public, synchronous read of a user's expenses — safe to call anytime,
  /// always reflects the current local cache instantly.
  List<Expense> getAllForUid(String uid) {
    final prefix = '${uid}_';
    final expenses = <Expense>[];

    for (final key in _box.keys) {
      if (key is! String || !key.startsWith(prefix)) continue;
      final raw = _box.get(key);
      if (raw == null) continue;
      try {
        final expense = Expense.fromMap(Map<String, dynamic>.from(raw as Map));
        if (expense.uid == uid) expenses.add(expense);
      } catch (_) {
        continue;
      }
    }

    expenses.sort((a, b) => b.date.compareTo(a.date));
    return expenses;
  }

  /// Fires whenever ANY key in the box changes — the cubit filters this
  /// down to whichever uid is currently active. A single subscription to
  /// this, held for the cubit's whole lifetime, avoids ever needing to
  /// cancel/resubscribe per account switch.
  Stream<void> get onBoxChanged => _box.watch().map((_) {});

  Future<void> syncFromRemoteIfEmpty(String uid) async {
    final hasLocalData = getAllForUid(uid).isNotEmpty;
    if (hasLocalData) return;
    try {
      final remote = await _service.fetchAll(uid);
      for (final expense in remote) {
        await _box.put(_keyFor(uid, expense.id), expense.copyWith(isSynced: true).toMap());
      }
    } catch (_) {
      // No connection, timeout, or other error — fine, just show an empty
      // list until the user is back online.
    }
  }

  Future<void> addExpense(Expense expense) async {
    await _box.put(_keyFor(expense.uid, expense.id), expense.toMap());
    _service.setExpense(expense).then((_) {
      _box.put(_keyFor(expense.uid, expense.id), expense.copyWith(isSynced: true).toMap());
    }).catchError((_) {});
  }

  Future<void> deleteExpense(String uid, String expenseId) async {
    await _box.delete(_keyFor(uid, expenseId));
    _service.deleteExpense(uid, expenseId).catchError((_) {});
  }
}