import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:moneyy/domain/repository/connectivity/connectivity_service.dart';

class ConnectivityService implements IConnectivityService {
  final Connectivity _connectivity = Connectivity();

  @override
  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map((ConnectivityResult result) {
      final isConnected = result != ConnectivityResult.none;
      return isConnected;
    });
  }
}
