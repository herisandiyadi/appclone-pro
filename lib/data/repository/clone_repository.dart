import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/engine/virtual_container.dart';
import '../model/clone_app.dart';

/// Persists cloned app list to SharedPreferences.
class CloneRepository {
  CloneRepository._();
  static final instance = CloneRepository._();

  static const _key = 'appclone_pro_clones_v1';

  Future<List<CloneApp>> loadClones() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_key);
      if (raw == null || raw.isEmpty) return _defaultClones;
      return raw.map((jsonStr) {
        final map = jsonDecode(jsonStr) as Map<String, dynamic>;
        return CloneApp.fromMap(map);
      }).toList();
    } catch (_) {
      return _defaultClones;
    }
  }

  Future<void> saveClones(List<CloneApp> clones) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = clones.map((c) => jsonEncode(c.toMap())).toList();
      await prefs.setStringList(_key, list);
    } catch (_) {
      // ignore in test / memory mode
    }
  }

  static final _defaultClones = [
    CloneApp(
      id: 'clone-demo-1',
      packageName: 'com.whatsapp',
      displayName: 'WhatsApp 2',
      appIconColor: 0xFF25D366,
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      storageBytes: 110 * 1024 * 1024,
      status: CloneStatus.ready,
    ),
    CloneApp(
      id: 'clone-demo-2',
      packageName: 'com.instagram.android',
      displayName: 'Instagram 2',
      appIconColor: 0xFFE1306C,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      storageBytes: 165 * 1024 * 1024,
      status: CloneStatus.ready,
    ),
  ];
}
