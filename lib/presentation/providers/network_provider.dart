import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../domain/entities/network_event.dart';
import '../../domain/entities/network_status.dart';
import '../../domain/entities/queued_request.dart';
import '../../domain/usecases/network_usecase.dart';

/// Drives the Network Monitor screen: keeps the active interface up to
/// date via a stream subscription, and manages a small in-memory queue of
/// simulated long-running requests that survive a Wi-Fi <-> Cellular
/// handover instead of crashing when the connection drops mid-flight.
class NetworkProvider extends ChangeNotifier {
  final NetworkUseCase useCase;

  NetworkStatus _status = NetworkStatus.offline;
  StreamSubscription<NetworkStatus>? _subscription;
  final List<NetworkEvent> _events = [];
  final List<QueuedRequest> _requests = [];
  int _requestCounter = 0;
  bool _isResuming = false;

  NetworkProvider(this.useCase) {
    _init();
  }

  NetworkStatus get status => _status;
  bool get isOnline => _status != NetworkStatus.offline;
  List<NetworkEvent> get events => List.unmodifiable(_events.reversed);
  List<QueuedRequest> get requests => List.unmodifiable(_requests.reversed);

  Future<void> _init() async {
    _status = await useCase.currentStatus();
    notifyListeners();
    _subscription = useCase.watchStatus().listen(_onStatusChanged);
  }

  void _onStatusChanged(NetworkStatus next) {
    if (next == _status) return;

    final previous = _status;
    _status = next;
    _events.add(
      NetworkEvent(timestamp: DateTime.now(), from: previous, to: next),
    );
    if (_events.length > 40) {
      _events.removeRange(0, _events.length - 40);
    }
    notifyListeners();

    // Connection came back (Wi-Fi or Cellular, in either direction) -
    // resume anything that got queued while it was down.
    if (next != NetworkStatus.offline) {
      _resumeQueuedRequests();
    }
  }

  /// Starts a simulated long-running dataset fetch. Ticks over a couple of
  /// seconds; if the interface drops mid-flight it's caught and the
  /// request is parked in the queue rather than throwing.
  void simulateRequest() {
    _requestCounter += 1;
    final request = QueuedRequest(
      id: 'req-$_requestCounter',
      label: 'Dataset fetch #$_requestCounter',
      createdAt: DateTime.now(),
      status: RequestStatus.inProgress,
      attempts: 1,
      progress: 0,
    );
    _requests.add(request);
    notifyListeners();
    unawaited(_runRequest(request));
  }

  Future<void> _runRequest(QueuedRequest request) async {
    const totalSteps = 8;
    try {
      for (var step = 1; step <= totalSteps; step++) {
        await Future.delayed(const Duration(milliseconds: 450));

        if (_status == NetworkStatus.offline) {
          // Handover/drop mid-request: catch it here instead of letting
          // it surface as an unhandled network error, and park it.
          _updateRequest(
            request.id,
            (r) => r.copyWith(status: RequestStatus.queued),
          );
          return;
        }

        _updateRequest(
          request.id,
          (r) => r.copyWith(progress: ((step / totalSteps) * 100).round()),
        );
      }

      _updateRequest(
        request.id,
        (r) => r.copyWith(status: RequestStatus.success, progress: 100),
      );
    } catch (_) {
      _updateRequest(request.id, (r) => r.copyWith(status: RequestStatus.failed));
    }
  }

  Future<void> _resumeQueuedRequests() async {
    if (_isResuming) return;
    final queuedIds = _requests
        .where((r) => r.status == RequestStatus.queued)
        .map((r) => r.id)
        .toList();
    if (queuedIds.isEmpty) return;

    _isResuming = true;
    for (final id in queuedIds) {
      final index = _requests.indexWhere((r) => r.id == id);
      if (index == -1) continue;

      final resumed = _requests[index].copyWith(
        status: RequestStatus.inProgress,
        attempts: _requests[index].attempts + 1,
        progress: 0,
      );
      _requests[index] = resumed;
      notifyListeners();
      await _runRequest(resumed);
    }
    _isResuming = false;
  }

  void _updateRequest(String id, QueuedRequest Function(QueuedRequest) update) {
    final index = _requests.indexWhere((r) => r.id == id);
    if (index == -1) return;
    _requests[index] = update(_requests[index]);
    notifyListeners();
  }

  void clearCompleted() {
    _requests.removeWhere((r) => r.status == RequestStatus.success);
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
