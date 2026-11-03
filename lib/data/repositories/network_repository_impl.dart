import 'package:connectivity_plus/connectivity_plus.dart';

import '../../domain/entities/network_status.dart';
import '../../domain/repositories/network_repository.dart';

/// Wraps `connectivity_plus` and reduces its result set down to the three
/// states the UI cares about. Wi-Fi/Ethernet take priority over cellular,
/// and an empty/`none` result means the device has no active interface.
class NetworkRepositoryImpl implements NetworkRepository {
  final Connectivity _connectivity;

  NetworkRepositoryImpl({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  @override
  Future<NetworkStatus> currentStatus() async {
    final results = await _connectivity.checkConnectivity();
    return _resolve(results);
  }

  @override
  Stream<NetworkStatus> watchStatus() {
    return _connectivity.onConnectivityChanged.map(_resolve);
  }

  NetworkStatus _resolve(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.wifi) ||
        results.contains(ConnectivityResult.ethernet)) {
      return NetworkStatus.wifi;
    }
    if (results.contains(ConnectivityResult.mobile)) {
      return NetworkStatus.cellular;
    }
    if (results.contains(ConnectivityResult.vpn)) {
      // A VPN result doesn't tell us the underlying transport; treat it as
      // an active connection rather than offline.
      return NetworkStatus.wifi;
    }
    return NetworkStatus.offline;
  }
}
