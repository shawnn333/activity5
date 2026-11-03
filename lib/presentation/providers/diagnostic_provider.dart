import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../domain/entities/diagnostic_result.dart';
import '../../domain/entities/network_health.dart';
import '../../domain/usecases/diagnostic_usecase.dart';

/// Runs the background diagnostic tool on a repeating timer and holds the
/// latest categorized result as app-wide state. Registered once, high in
/// the widget tree (see main.dart), so ANY screen can read the current
/// [tier] via `context.watch<DiagnosticProvider>()` - not just the
/// dashboard itself - which is what makes the health status "broadcast"
/// across the app rather than being local UI state on one screen.
class DiagnosticProvider extends ChangeNotifier {
  final DiagnosticUseCase useCase;
  static const _interval = Duration(seconds: 20);

  Timer? _timer;
  DiagnosticResult? _latest;
  final List<DiagnosticResult> _history = [];
  bool _isRunning = false;
  String _currentStep = 'Idle';

  DiagnosticProvider(this.useCase) {
    unawaited(_runNow());
    _timer = Timer.periodic(_interval, (_) => _runNow());
  }

  DiagnosticResult? get latest => _latest;
  NetworkHealthTier? get tier => _latest?.tier;
  bool get isRunning => _isRunning;
  String get currentStep => _currentStep;
  List<DiagnosticResult> get history => List.unmodifiable(_history.reversed);

  Future<void> runNow() => _runNow();

  Future<void> _runNow() async {
    if (_isRunning) return;
    _isRunning = true;
    notifyListeners();

    final result = await useCase.run(
      onStep: (step) {
        _currentStep = step;
        notifyListeners();
      },
    );

    _latest = result;
    _history.add(result);
    if (_history.length > 20) {
      _history.removeRange(0, _history.length - 20);
    }
    _isRunning = false;
    _currentStep = 'Idle';
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
