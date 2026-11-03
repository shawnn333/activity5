import '../entities/network_status.dart';

abstract class NetworkRepository {
  Future<NetworkStatus> currentStatus();
  Stream<NetworkStatus> watchStatus();
}
