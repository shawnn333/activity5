import '../entities/network_status.dart';
import '../repositories/network_repository.dart';

class NetworkUseCase {
  final NetworkRepository repository;

  NetworkUseCase(this.repository);

  Future<NetworkStatus> currentStatus() => repository.currentStatus();

  Stream<NetworkStatus> watchStatus() => repository.watchStatus();
}
