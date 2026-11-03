import '../entities/diagnostic_result.dart';

abstract class DiagnosticRepository {
  /// Runs the idle-ping -> download -> upload sequence and returns a
  /// categorized result. [onStep] is invoked with a short label for each
  /// phase so the UI can reflect progress while it runs.
  Future<DiagnosticResult> runDiagnostic({
    void Function(String step)? onStep,
  });
}
