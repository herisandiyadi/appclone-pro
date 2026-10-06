/// Virtual container — simulates process/filesystem isolation per clone.
/// On real Android this maps to VirtualApp-style UID isolation.
/// On this simulation layer it uses in-memory state + filesystem sandboxing.
library;

import 'dart:async';
import 'dart:math';

import '../engine/engine_models.dart';

enum CloneStatus { cloning, ready, running, error }

class VirtualContainer {
  VirtualContainer({required this.cloneId, required this.packageName});

  final String cloneId;
  final String packageName;

  VirtualProcessState _processState = VirtualProcessState.stopped;
  final List<EngineLog> _logs = [];
  int _memoryMb = 0;

  VirtualProcessState get processState => _processState;
  List<EngineLog> get logs => List.unmodifiable(_logs);
  int get memoryMb => _memoryMb;

  final _logController = StreamController<EngineLog>.broadcast();
  Stream<EngineLog> get logStream => _logController.stream;

  /// Simulate launching the cloned app inside virtual container.
  Future<VirtualProcess> launch() async {
    _log(EngineLogLevel.info, 'container', 'Launching $packageName in container $cloneId');
    _processState = VirtualProcessState.starting;

    // Simulate startup latency
    await Future.delayed(const Duration(milliseconds: 800));
    _memoryMb = 30 + Random().nextInt(40);
    _processState = VirtualProcessState.running;

    _log(EngineLogLevel.info, 'container', 'Process running, memory: ${_memoryMb}MB');

    return VirtualProcess(
      pid: Random().nextInt(99999) + 10000,
      cloneId: cloneId,
      packageName: packageName,
      state: VirtualProcessState.running,
      startedAt: DateTime.now(),
      memoryMb: _memoryMb,
    );
  }

  /// Pause (background) the container.
  Future<void> pause() async {
    if (_processState == VirtualProcessState.running) {
      _processState = VirtualProcessState.paused;
      _memoryMb = (_memoryMb * 0.3).round(); // compress
      _log(EngineLogLevel.info, 'container', 'Paused — memory compressed to ${_memoryMb}MB');
    }
  }

  /// Kill the container process.
  Future<void> kill() async {
    _processState = VirtualProcessState.killed;
    _memoryMb = 0;
    _log(EngineLogLevel.info, 'container', 'Process killed');
  }

  void _log(EngineLogLevel level, String component, String message) {
    final entry = EngineLog(
      timestamp: DateTime.now(),
      level: level,
      component: component,
      message: message,
    );
    _logs.add(entry);
    if (!_logController.isClosed) _logController.add(entry);
  }

  void dispose() {
    _logController.close();
  }
}
