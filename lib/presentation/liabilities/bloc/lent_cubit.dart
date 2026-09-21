import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/lent_repository.dart';
import 'lent_state.dart';

class LentCubit extends Cubit<LentState> {
  final LentRepository _repository;
  StreamSubscription<void>? _boxSubscription;
  String? _currentUid;

  LentCubit(this._repository) : super(const LentState.initial()) {
    _boxSubscription = _repository.onBoxChanged.listen((_) {
      final uid = _currentUid;
      if (uid == null) return;
      emit(LentState(isLoading: false, lents: _repository.getAllForUid(uid)));
    });
  }

  Future<void> load(String uid) async {
    if (_currentUid != uid) {
      emit(const LentState.initial());
    }
    _currentUid = uid;
    await _repository.syncFromRemoteIfEmpty(uid);
    emit(LentState(isLoading: false, lents: _repository.getAllForUid(uid)));
  }

  Future<void> save(lent) => _repository.saveLent(lent);
  Future<void> delete(String uid, String id) => _repository.deleteLent(uid, id);

  Future<void> clearOnSignOut() async {
    _currentUid = null;
    emit(const LentState.initial());
  }

  @override
  Future<void> close() {
    _boxSubscription?.cancel();
    return super.close();
  }
}