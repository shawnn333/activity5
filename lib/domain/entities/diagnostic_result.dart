import 'network_health.dart';

class DiagnosticResult {
  final DateTime timestamp;
  final double idlePingMs;
  final double downloadMbps;
  final double downloadPingMs;
  final double uploadMbps;
  final double uploadPingMs;
  final double packetLossPercent;
  final NetworkHealthTier tier;

  const DiagnosticResult({
    required this.timestamp,
    required this.idlePingMs,
    required this.downloadMbps,
    required this.downloadPingMs,
    required this.uploadMbps,
    required this.uploadPingMs,
    required this.packetLossPercent,
    required this.tier,
  });
}
