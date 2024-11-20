abstract class IConnectivityService {
  /// Stream to monitor connectivity changes.
  Stream<bool> get onConnectivityChanged;
}