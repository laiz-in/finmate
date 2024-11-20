import 'package:firebase_database/firebase_database.dart';
import 'package:moneyy/domain/repository/connectivity/connectivity_service.dart';


class ConnectivityService implements IConnectivityService {
  final DatabaseReference connectedRef = FirebaseDatabase.instance.ref(".info/connected");

  @override
  Stream<bool> get onConnectivityChanged {
    return connectedRef.onValue.map((event) {
      final connected = event.snapshot.value as bool? ?? false;
      return connected;
    });
  }
}
