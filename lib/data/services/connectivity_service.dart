import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final InternetConnection _internetChecker = InternetConnection();

  /// A reliable, debounced stream of true (online) / false (offline).
  /// Combines raw network-type changes with an actual reachability check,
  /// since being connected to a network doesn't guarantee real internet access.
  Stream<bool> get onStatusChange {
    late final StreamController<bool> controller;
    StreamSubscription? connectivitySub;
    StreamSubscription? internetSub;
    Timer? debounce;

    void emitDebounced(bool value) {
      debounce?.cancel();
      debounce = Timer(const Duration(milliseconds: 600), () {
        if (!controller.isClosed) controller.add(value);
      });
    }

    controller = StreamController<bool>.broadcast(
      onListen: () {
        // React quickly to network type changes (WiFi/mobile/none) by re-verifying real internet.
        connectivitySub = _connectivity.onConnectivityChanged.listen((_) async {
          final hasInternet = await _internetChecker.hasInternetAccess;
          emitDebounced(hasInternet);
        });

        // Authoritative reachability stream (actual ping-based check).
        internetSub = _internetChecker.onStatusChange.listen((status) {
          emitDebounced(status == InternetStatus.connected);
        });
      },
      onCancel: () {
        connectivitySub?.cancel();
        internetSub?.cancel();
        debounce?.cancel();
      },
    );

    return controller.stream;
  }

  /// One-off check — use before executing a network-required action
  /// (e.g. creating a group, calculating balances) as a pre-flight check.
  /// Always still wrap the actual network call in try/catch as the final safety net.
  Future<bool> checkNow() async {
    return _internetChecker.hasInternetAccess;
  }
}