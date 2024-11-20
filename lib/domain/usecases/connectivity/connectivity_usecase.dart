import "package:moneyy/domain/repository/connectivity/connectivity_service.dart";

class GetConnectivityStatus {
  final IConnectivityService connectivityService;

  GetConnectivityStatus(this.connectivityService);

  Stream<bool> call() => connectivityService.onConnectivityChanged;
}