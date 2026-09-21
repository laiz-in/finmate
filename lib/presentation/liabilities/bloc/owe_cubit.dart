import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/owe_repository.dart';
import 'owe_state.dart';

class OweCubit extends Cubit<OweState> {
  final OweRepository _repository;
  StreamSubscription<void>? _boxSubscription;
  String? _currentUid;

  OweCubit(this._repository) : super(const OweState.initial()) {
    _boxSubscription = _repository.onBoxChanged.listen((_) {
      final uid = _currentUid;
      if (uid == null) return;
      emit(OweState(isLoading: false, owes: _repository.getAllForUid(uid)));
    });
  }

  Future<void> load(String uid) async {
    if (_currentUid != uid) {
      emit(const OweState.initial());
    }
    _currentUid = uid;
    await _repository.syncFromRemoteIfEmpty(uid);
    emit(OweState(isLoading: false, owes: _repository.getAllForUid(uid)));
  }

  Future<void> save(owe) => _repository.saveOwe(owe);
  Future<void> delete(String uid, String id) => _repository.deleteOwe(uid, id);

  Future<void> clearOnSignOut() async {
    _currentUid = null;
    emit(const OweState.initial());
  }

  @override
  Future<void> close() {
    _boxSubscription?.cancel();
    return super.close();
  }
}