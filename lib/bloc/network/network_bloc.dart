import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moneyy/domain/usecases/connectivity/connectivity_usecase.dart';

class ConnectivityCubit extends Cubit<bool> {
  final GetConnectivityStatus getConnectivityStatus;

  ConnectivityCubit(this.getConnectivityStatus) : super(false) {
    print("came to cubit connectivity");
    _monitorConnectivity();
  }

  void _monitorConnectivity() {
    
    getConnectivityStatus().listen((isConnected) {
      print("emitting isconnected");
      print(isConnected);
      emit(isConnected);
    });
  }
}
