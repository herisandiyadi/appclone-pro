import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/model/installed_app.dart';

/// Calls the Android native bridge (MainActivity.kt) via platform channel.
/// Falls back to mock data when running on desktop / test runner.
class NativeBridge {
  NativeBridge._();
  static final instance = NativeBridge._();

  static const _channel = MethodChannel('appclone_pro/native');

  /// Fetch launchable apps installed on the device.
  Future<List<InstalledApp>> getInstalledApps() async {
    try {
      final List<dynamic>? raw = await _channel.invokeMethod('getInstalledApps');
      if (raw == null || raw.isEmpty) return _fallbackApps;
      return raw.map((item) {
        final map = Map<String, dynamic>.from(item as Map);
        return InstalledApp(
          packageName: map['packageName'] as String? ?? 'unknown',
          appName: map['appName'] as String? ?? 'Unknown App',
          icon: Icons.android,
          sizeBytes: 50 * 1024 * 1024,
        );
      }).toList();
    } on MissingPluginException {
      // In test or non-Android environment
      return _fallbackApps;
    } catch (_) {
      return _fallbackApps;
    }
  }

  /// Launch the real app via Android launch intent.
  /// Returns true if the app was found and opened.
  Future<bool> launchApp(String packageName) async {
    try {
      final bool? launched =
          await _channel.invokeMethod('launchApp', {'packageName': packageName});
      return launched ?? false;
    } on MissingPluginException {
      return false;
    } catch (_) {
      return false;
    }
  }

  static const _fallbackApps = [
    InstalledApp(packageName: 'com.whatsapp', appName: 'WhatsApp', icon: Icons.chat, sizeBytes: 85 * 1024 * 1024),
    InstalledApp(packageName: 'com.instagram.android', appName: 'Instagram', icon: Icons.camera_alt, sizeBytes: 140 * 1024 * 1024),
    InstalledApp(packageName: 'com.facebook.katana', appName: 'Facebook', icon: Icons.facebook, sizeBytes: 180 * 1024 * 1024),
    InstalledApp(packageName: 'com.zhiliaoapp.musically', appName: 'TikTok', icon: Icons.video_collection, sizeBytes: 195 * 1024 * 1024),
    InstalledApp(packageName: 'com.telegram.messenger', appName: 'Telegram', icon: Icons.send, sizeBytes: 95 * 1024 * 1024),
  ];
}
