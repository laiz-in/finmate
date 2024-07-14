import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Events
abstract class ConnectivityEvent {}
class CheckConnectivity extends ConnectivityEvent {}

// States
abstract class ConnectivityState {}
class ConnectedState extends ConnectivityState {}
class DisconnectedState extends ConnectivityState {}

class ConnectivityBloc extends Bloc<ConnectivityEvent, ConnectivityState> {
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  ConnectivityBloc() : super(ConnectedState()) {
    on<CheckConnectivity>(_onCheckConnectivity);
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((_) {
      add(CheckConnectivity());
    });
  }

  Future<void> _onCheckConnectivity(CheckConnectivity event, Emitter<ConnectivityState> emit) async {
    final result = await _connectivity.checkConnectivity();
    if (result == ConnectivityResult.none) {
      emit(DisconnectedState());
    } else {
      emit(ConnectedState());
    }
  }

  @override
  Future<void> close() {
    _connectivitySubscription.cancel();
    return super.close();
  }
}