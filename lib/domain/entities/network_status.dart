enum NetworkStatus { wifi, cellular, offline }

extension NetworkStatusX on NetworkStatus {
  String get label {
    switch (this) {
      case NetworkStatus.wifi:
        return 'Wi-Fi';
      case NetworkStatus.cellular:
        return 'Cellular';
      case NetworkStatus.offline:
        return 'Offline';
    }
  }
}
