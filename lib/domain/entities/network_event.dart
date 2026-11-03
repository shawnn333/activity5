import 'network_status.dart';

class NetworkEvent {
  final DateTime timestamp;
  final NetworkStatus from;
  final NetworkStatus to;

  const NetworkEvent({
    required this.timestamp,
    required this.from,
    required this.to,
  });
}
