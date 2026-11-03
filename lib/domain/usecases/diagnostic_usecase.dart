import '../entities/diagnostic_result.dart';
import '../repositories/diagnostic_repository.dart';

class DiagnosticUseCase {
  final DiagnosticRepository repository;

  DiagnosticUseCase(this.repository);

  Future<DiagnosticResult> run({void Function(String step)? onStep}) {
    return repository.runDiagnostic(onStep: onStep);
  }
}
