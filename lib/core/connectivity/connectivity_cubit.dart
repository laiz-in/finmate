import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/services/connectivity_service.dart';

class ConnectivityCubit extends Cubit<bool> {
  final ConnectivityService _service;
  StreamSubscription<bool>? _subscription;

  // Assume online initially to avoid a false "offline" flash on app start;
  // corrected almost immediately once the first real check comes in.
  ConnectivityCubit(this._service) : super(true) {
    _init();
  }

  Future<void> _init() async {
    final initial = await _service.checkNow();
    emit(initial);
    _subscription = _service.onStatusChange.listen(emit);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}