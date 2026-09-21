import 'package:hive/hive.dart';

import '../models/lent.dart';
import '../services/lent_service.dart';

class LentRepository {
  final LentService _service;
  final Box _box = Hive.box('lentsBox');

  LentRepository(this._service);

  String _keyFor(String uid, String id) => '${uid}_$id';

  List<Lent> getAllForUid(String uid) {
    final prefix = '${uid}_';
    final items = <Lent>[];
    for (final key in _box.keys) {
      if (key is! String || !key.startsWith(prefix)) continue;
      final raw = _box.get(key);
      if (raw == null) continue;
      try {
        final lent = Lent.fromMap(Map<String, dynamic>.from(raw as Map));
        if (lent.uid == uid) items.add(lent);
      } catch (_) {
        continue;
      }
    }
    items.sort((a, b) => a.isSettled == b.isSettled ? b.dueDate.compareTo(a.dueDate) : (a.isSettled ? 1 : -1));
    return items;
  }

  Stream<void> get onBoxChanged => _box.watch().map((_) {});

  Future<void> syncFromRemoteIfEmpty(String uid) async {
    if (getAllForUid(uid).isNotEmpty) return;
    try {
      final remote = await _service.fetchAll(uid);
      for (final lent in remote) {
        await _box.put(_keyFor(uid, lent.id), lent.copyWith(isSynced: true).toMap());
      }
    } catch (_) {}
  }

  Future<void> saveLent(Lent lent) async {
    await _box.put(_keyFor(lent.uid, lent.id), lent.toMap());
    _service.setLent(lent).then((_) {
      _box.put(_keyFor(lent.uid, lent.id), lent.copyWith(isSynced: true).toMap());
    }).catchError((_) {});
  }

  Future<void> deleteLent(String uid, String id) async {
    await _box.delete(_keyFor(uid, id));
    _service.deleteLent(uid, id).catchError((_) {});
  }
}