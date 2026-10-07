/// CloningEngine — orchestrates the full clone lifecycle.
library;

import 'dart:async';
import 'dart:math';

import 'engine_models.dart';
import 'virtual_container.dart';
import '../../data/model/clone_app.dart';

/// Progress event emitted during clone creation.
class CloneProgress {
  const CloneProgress({required this.step, required this.percent, this.message = ''});
  final CloningStep step;
  final double percent; // 0.0 – 1.0
  final String message;
}

enum CloningStep { parsing, copying, installing, isolating, finalizing, done, failed }

class CloningEngine {
  CloningEngine._();
  static final instance = CloningEngine._();

  final Map<String, VirtualContainer> _containers = {};
  final Map<String, VirtualProcess> _processes = {};

  /// Create a clone, emitting progress events.
  Stream<CloneProgress> createClone(CloneApp app) async* {
    yield const CloneProgress(step: CloningStep.parsing, percent: 0.1, message: 'Parsing APK manifest...');
    await _delay(400);

    yield const CloneProgress(step: CloningStep.copying, percent: 0.3, message: 'Copying APK to virtual storage...');
    await _delay(600);

    yield const CloneProgress(step: CloningStep.installing, percent: 0.55, message: 'Installing in virtual container...');
    await _delay(700);

    yield const CloneProgress(step: CloningStep.isolating, percent: 0.75, message: 'Applying process isolation...');
    await _delay(400);

    yield const CloneProgress(step: CloningStep.finalizing, percent: 0.9, message: 'Finalizing permissions...');
    await _delay(400);

    final container = VirtualContainer(cloneId: app.id, packageName: app.packageName);
    _containers[app.id] = container;

    yield const CloneProgress(step: CloningStep.done, percent: 1.0, message: 'Clone ready.');
  }

  /// Launch an existing clone. Auto-registers a container when missing
  /// (simulation layer: containers are in-memory, lost on restart).
  Future<VirtualProcess?> launchClone(CloneApp clone) async {
    final container =
        _containers[clone.id] ?? VirtualContainer(cloneId: clone.id, packageName: clone.packageName);
    _containers[clone.id] = container;
    final process = await container.launch();
    _processes[clone.id] = process;
    return process;
  }

  Future<void> pauseClone(String cloneId) async {
    await _containers[cloneId]?.pause();
    _processes.remove(cloneId);
  }

  Future<void> killClone(String cloneId) async {
    await _containers[cloneId]?.kill();
    _processes.remove(cloneId);
  }

  void removeClone(String cloneId) {
    _containers[cloneId]?.dispose();
    _containers.remove(cloneId);
    _processes.remove(cloneId);
  }

  bool isRunning(String cloneId) =>
      _processes.containsKey(cloneId) && (_processes[cloneId]?.isAlive ?? false);

  VirtualContainer? getContainer(String cloneId) => _containers[cloneId];

  int get totalMemoryMb => _containers.values.fold(0, (sum, c) => sum + c.memoryMb);

  Future<void> _delay(int ms) =>
      Future.delayed(Duration(milliseconds: ms + Random().nextInt(200)));
}
