import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/engine/cloning_engine.dart';
import '../../core/engine/native_bridge.dart';
import '../../core/notification/notification_handler.dart';
import '../../core/security/security_manager.dart';
import '../../data/model/clone_app.dart';
import '../../data/model/installed_app.dart';
import '../../data/repository/clone_repository.dart';

final cloningEngineProvider = Provider((ref) => CloningEngine.instance);
final nativeBridgeProvider = Provider((ref) => NativeBridge.instance);
final notificationHandlerProvider = Provider((ref) => NotificationHandler.instance);
final securityManagerProvider = Provider((ref) => SecurityManager.instance);
final cloneRepositoryProvider = Provider((ref) => CloneRepository.instance);

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);

final installedAppsProvider = FutureProvider<List<InstalledApp>>((ref) async {
  return ref.watch(nativeBridgeProvider).getInstalledApps();
});

final clonesListProvider = StateNotifierProvider<ClonesNotifier, List<CloneApp>>((ref) {
  final repo = ref.watch(cloneRepositoryProvider);
  final notifier = ClonesNotifier(repo);
  notifier.init();
  return notifier;
});

class ClonesNotifier extends StateNotifier<List<CloneApp>> {
  ClonesNotifier(this.repo) : super([]);

  final CloneRepository repo;

  Future<void> init() async {
    final loaded = await repo.loadClones();
    state = loaded;
  }

  void addClone(CloneApp clone) {
    state = [...state, clone];
    repo.saveClones(state);
  }

  void updateClone(CloneApp clone) {
    state = [
      for (final c in state)
        if (c.id == clone.id) clone else c
    ];
    repo.saveClones(state);
  }

  void renameClone(String id, String newName) {
    state = [
      for (final c in state)
        if (c.id == id) c.copyWith(displayName: newName) else c
    ];
    repo.saveClones(state);
  }

  void changeIconColor(String id, int color) {
    state = [
      for (final c in state)
        if (c.id == id)
          CloneApp(
            id: c.id,
            packageName: c.packageName,
            displayName: c.displayName,
            appIconColor: color,
            createdAt: c.createdAt,
            locked: c.locked,
            hidden: c.hidden,
            storageBytes: c.storageBytes,
            status: c.status,
          )
        else
          c
    ];
    repo.saveClones(state);
  }

  void removeClone(String id) {
    state = state.where((c) => c.id != id).toList();
    repo.saveClones(state);
  }

  void toggleLock(String id) {
    state = [
      for (final c in state)
        if (c.id == id) c.copyWith(locked: !c.locked) else c
    ];
    repo.saveClones(state);
  }

  void toggleHide(String id) {
    state = [
      for (final c in state)
        if (c.id == id) c.copyWith(hidden: !c.hidden) else c
    ];
    repo.saveClones(state);
  }
}
