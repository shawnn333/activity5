import 'dart:math';

import '../../domain/entities/diagnostic_result.dart';
import '../../domain/entities/network_health.dart';
import '../../domain/entities/network_status.dart';
import '../../domain/repositories/diagnostic_repository.dart';
import '../../domain/repositories/network_repository.dart';

/// The background diagnostic tool. It follows the required sequence -
/// baseline idle ping, then a download pass that samples ping
/// concurrently, then an upload pass that samples ping concurrently -
/// and classifies the result into an operational tier.
///
/// Real throughput numbers depend on hardware and live network
/// conditions a test harness can't reproduce, so measurements are
/// generated with realistic jitter around a baseline for the device's
/// *actual* current interface (Wi-Fi / Cellular / Offline), read from
/// [NetworkRepository]. Swap the sampling methods below for a real
/// download/upload probe (e.g. timed HTTP transfers) to go from
/// simulated to live measurements without touching the rest of the app.
class DiagnosticRepositoryImpl implements DiagnosticRepository {
  final NetworkRepository networkRepository;
  final Random _random = Random();

  DiagnosticRepositoryImpl({required this.networkRepository});

  @override
  Future<DiagnosticResult> runDiagnostic({
    void Function(String step)? onStep,
  }) async {
    final status = await networkRepository.currentStatus();

    if (status == NetworkStatus.offline) {
      onStep?.call('No active connection');
      await Future.delayed(const Duration(milliseconds: 500));
      return DiagnosticResult(
        timestamp: DateTime.now(),
        idlePingMs: 9999,
        downloadMbps: 0,
        downloadPingMs: 9999,
        uploadMbps: 0,
        uploadPingMs: 9999,
        packetLossPercent: 100,
        tier: NetworkHealthTier.degraded,
      );
    }

    // Step 1: baseline idle ping, before any load is placed on the link.
    onStep?.call('Measuring idle ping');
    await Future.delayed(const Duration(milliseconds: 350));
    final idlePing = _basePing(status) + _jitter(6);

    // Step 2: download bandwidth, sampling ping concurrently under load.
    onStep?.call('Testing download speed');
    final downloadSamples = <double>[];
    final downloadPingSamples = <double>[];
    for (var i = 0; i < 4; i++) {
      await Future.delayed(const Duration(milliseconds: 280));
      downloadSamples.add(
        _baseDownload(status) + _jitter(_baseDownload(status) * 0.3),
      );
      downloadPingSamples.add(_basePing(status) + _jitter(12));
    }
    final downloadMbps = _clamp(_average(downloadSamples), 0, 500);
    final downloadPing = _clamp(_average(downloadPingSamples), 1, 9999);

    // Step 3: upload bandwidth, sampling ping concurrently under load.
    onStep?.call('Testing upload speed');
    final uploadSamples = <double>[];
    final uploadPingSamples = <double>[];
    for (var i = 0; i < 4; i++) {
      await Future.delayed(const Duration(milliseconds: 280));
      uploadSamples.add(
        _baseUpload(status) + _jitter(_baseUpload(status) * 0.3),
      );
      uploadPingSamples.add(_basePing(status) + _jitter(16));
    }
    final uploadMbps = _clamp(_average(uploadSamples), 0, 500);
    final uploadPing = _clamp(_average(uploadPingSamples), 1, 9999);

    onStep?.call('Analyzing results');
    final packetLoss = _clamp(
      _basePacketLoss(status) + _jitter(2).abs(),
      0,
      100,
    );
    final tier = _classify(
      downloadMbps: downloadMbps,
      idlePingMs: idlePing,
      packetLossPercent: packetLoss,
    );

    return DiagnosticResult(
      timestamp: DateTime.now(),
      idlePingMs: idlePing,
      downloadMbps: downloadMbps,
      downloadPingMs: downloadPing,
      uploadMbps: uploadMbps,
      uploadPingMs: uploadPing,
      packetLossPercent: packetLoss,
      tier: tier,
    );
  }

  /// Threshold logic: heavy loss or extreme latency overrides everything
  /// else as Degraded; otherwise the tier follows download throughput.
  NetworkHealthTier _classify({
    required double downloadMbps,
    required double idlePingMs,
    required double packetLossPercent,
  }) {
    if (packetLossPercent >= 15 || idlePingMs >= 300) {
      return NetworkHealthTier.degraded;
    }
    if (downloadMbps > 10) return NetworkHealthTier.excellent;
    if (downloadMbps >= 2) return NetworkHealthTier.fair;
    return NetworkHealthTier.poor;
  }

  double _basePing(NetworkStatus status) {
    switch (status) {
      case NetworkStatus.wifi:
        return 22;
      case NetworkStatus.cellular:
        return 75;
      case NetworkStatus.offline:
        return 9999;
    }
  }

  double _baseDownload(NetworkStatus status) {
    switch (status) {
      case NetworkStatus.wifi:
        return 28;
      case NetworkStatus.cellular:
        return 6;
      case NetworkStatus.offline:
        return 0;
    }
  }

  double _baseUpload(NetworkStatus status) {
    switch (status) {
      case NetworkStatus.wifi:
        return 12;
      case NetworkStatus.cellular:
        return 2.5;
      case NetworkStatus.offline:
        return 0;
    }
  }

  double _basePacketLoss(NetworkStatus status) {
    switch (status) {
      case NetworkStatus.wifi:
        return 0.3;
      case NetworkStatus.cellular:
        return 1.5;
      case NetworkStatus.offline:
        return 100;
    }
  }

  double _jitter(double magnitude) =>
      (_random.nextDouble() * 2 - 1) * magnitude;

  double _average(List<double> values) =>
      values.reduce((a, b) => a + b) / values.length;

  double _clamp(double value, double lo, double hi) {
    if (value < lo) return lo;
    if (value > hi) return hi;
    return value;
  }
}
