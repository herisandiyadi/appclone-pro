import 'package:flutter/material.dart';

/// An app available on the device to be cloned.
class InstalledApp {
  const InstalledApp({
    required this.packageName,
    required this.appName,
    required this.icon,
    required this.sizeBytes,
    this.isClonable = true,
  });

  final String packageName;
  final String appName;
  final IconData icon;
  final int sizeBytes;
  final bool isClonable;
}
