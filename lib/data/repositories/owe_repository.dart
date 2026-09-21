import 'package:hive/hive.dart';

import '../models/owe.dart';
import '../services/owe_service.dart';

class OweRepository {
  final OweService _service;
  final Box _box = Hive.box('owesBox');

  OweRepository(this._service);

  String _keyFor(String uid, String id) => '${uid}_$id';

  List<Owe> getAllForUid(String uid) {
    final prefix = '${uid}_';
    final items = <Owe>[];
    for (final key in _box.keys) {
      if (key is! String || !key.startsWith(prefix)) continue;
      final raw = _box.get(key);
      if (raw == null) continue;
      try {
        final owe = Owe.fromMap(Map<String, dynamic>.from(raw as Map));
        if (owe.uid == uid) items.add(owe);
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
      for (final owe in remote) {
        await _box.put(_keyFor(uid, owe.id), owe.copyWith(isSynced: true).toMap());
      }
    } catch (_) {}
  }

  Future<void> saveOwe(Owe owe) async {
    await _box.put(_keyFor(owe.uid, owe.id), owe.toMap());
    _service.setOwe(owe).then((_) {
      _box.put(_keyFor(owe.uid, owe.id), owe.copyWith(isSynced: true).toMap());
    }).catchError((_) {});
  }

  Future<void> deleteOwe(String uid, String id) async {
    await _box.delete(_keyFor(uid, id));
    _service.deleteOwe(uid, id).catchError((_) {});
  }
}