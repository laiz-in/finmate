import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'network_event.dart';
import 'network_state.dart';

class NetworkBloc extends Bloc<NetworkEvent, NetworkState> {
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription _connectivitySubscription;

  NetworkBloc() : super(NetworkInitial()) {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((result) {
      if (result == ConnectivityResult.none) {
        add(NetworkStatusChanged(false)); // Disconnected
      } else {
        add(NetworkStatusChanged(true)); // Connected
      }
    });

    on<NetworkStatusChanged>((event, emit) {
      if (event.isConnected) {
        emit(NetworkConnected());
      } else {
        emit(NetworkDisconnected());
      }
    });
  }

  @override
  Future<void> close() {
    _connectivitySubscription.cancel();
    return super.close();
  }
}
