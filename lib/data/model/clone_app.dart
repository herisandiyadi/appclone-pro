import 'package:uuid/uuid.dart';

import '../../core/engine/virtual_container.dart';

/// Represents one cloned instance of an installed app.
class CloneApp {
  CloneApp({
    required this.id,
    required this.packageName,
    required this.displayName,
    required this.appIconColor,
    required this.createdAt,
    this.locked = false,
    this.hidden = false,
    this.storageBytes = 0,
    this.status = CloneStatus.ready,
  });

  final String id;
  final String packageName;
  final String displayName;
  final int appIconColor;
  final DateTime createdAt;
  bool locked;
  bool hidden;
  int storageBytes;
  CloneStatus status;

  Map<String, dynamic> toMap() => {
        'id': id,
        'packageName': packageName,
        'displayName': displayName,
        'appIconColor': appIconColor,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'locked': locked ? 1 : 0,
        'hidden': hidden ? 1 : 0,
        'storageBytes': storageBytes,
        'status': status.name,
      };

  factory CloneApp.fromMap(Map<String, dynamic> map) => CloneApp(
        id: map['id'] as String,
        packageName: map['packageName'] as String,
        displayName: map['displayName'] as String,
        appIconColor: map['appIconColor'] as int,
        createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
        locked: (map['locked'] as int? ?? 0) == 1,
        hidden: (map['hidden'] as int? ?? 0) == 1,
        storageBytes: map['storageBytes'] as int? ?? 0,
        status: CloneStatus.values.firstWhere(
          (s) => s.name == map['status'],
          orElse: () => CloneStatus.ready,
        ),
      );

  static CloneApp create({
    required String packageName,
    required String displayName,
    required int appIconColor,
  }) {
    return CloneApp(
      id: const Uuid().v4(),
      packageName: packageName,
      displayName: displayName,
      appIconColor: appIconColor,
      createdAt: DateTime.now(),
      status: CloneStatus.cloning,
    );
  }

  CloneApp copyWith({
    String? displayName,
    bool? locked,
    bool? hidden,
    int? storageBytes,
    CloneStatus? status,
  }) {
    return CloneApp(
      id: id,
      packageName: packageName,
      displayName: displayName ?? this.displayName,
      appIconColor: appIconColor,
      createdAt: createdAt,
      locked: locked ?? this.locked,
      hidden: hidden ?? this.hidden,
      storageBytes: storageBytes ?? this.storageBytes,
      status: status ?? this.status,
    );
  }
}
