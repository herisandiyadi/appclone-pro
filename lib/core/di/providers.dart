import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/engine/cloning_engine.dart';
import '../../core/engine/native_bridge.dart';
import '../../core/engine/virtual_container.dart';
import '../../core/notification/notification_handler.dart';
import '../../core/security/security_manager.dart';
import '../../data/model/clone_app.dart';
import '../../data/model/installed_app.dart';

final cloningEngineProvider = Provider((ref) => CloningEngine.instance);
final nativeBridgeProvider = Provider((ref) => NativeBridge.instance);
final notificationHandlerProvider = Provider((ref) => NotificationHandler.instance);
final securityManagerProvider = Provider((ref) => SecurityManager.instance);

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);

final installedAppsProvider = FutureProvider<List<InstalledApp>>((ref) async {
  return ref.watch(nativeBridgeProvider).getInstalledApps();
});

final clonesListProvider = StateNotifierProvider<ClonesNotifier, List<CloneApp>>((ref) {
  return ClonesNotifier(ref);
});

class ClonesNotifier extends StateNotifier<List<CloneApp>> {
  ClonesNotifier(this.ref) : super([
    CloneApp(
      id: 'clone-demo-1',
      packageName: 'com.whatsapp',
      displayName: 'WhatsApp Business',
      appIconColor: 0xFF25D366,
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      storageBytes: 110 * 1024 * 1024,
      status: CloneStatus.ready,
    ),
    CloneApp(
      id: 'clone-demo-2',
      packageName: 'com.instagram.android',
      displayName: 'IG Creator',
      appIconColor: 0xFFE1306C,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      storageBytes: 165 * 1024 * 1024,
      status: CloneStatus.ready,
    ),
  ]);

  final Ref ref;

  void addClone(CloneApp clone) {
    state = [...state, clone];
  }

  void updateClone(CloneApp clone) {
    state = [
      for (final c in state)
        if (c.id == clone.id) clone else c
    ];
  }

  void removeClone(String id) {
    state = state.where((c) => c.id != id).toList();
  }

  void toggleLock(String id) {
    state = [
      for (final c in state)
        if (c.id == id) c.copyWith(locked: !c.locked) else c
    ];
  }

  void toggleHide(String id) {
    state = [
      for (final c in state)
        if (c.id == id) c.copyWith(hidden: !c.hidden) else c
    ];
  }
}
