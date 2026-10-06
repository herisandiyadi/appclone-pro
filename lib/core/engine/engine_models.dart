import 'package:meta/meta.dart';

/// Virtual process representation inside the container.
@immutable
class VirtualProcess {
  const VirtualProcess({
    required this.pid,
    required this.cloneId,
    required this.packageName,
    required this.state,
    required this.startedAt,
    this.memoryMb = 0,
  });

  final int pid;
  final String cloneId;
  final String packageName;
  final VirtualProcessState state;
  final DateTime startedAt;
  final int memoryMb;

  bool get isAlive => state == VirtualProcessState.running;
}

enum VirtualProcessState { starting, running, paused, stopped, killed }

/// A notification forwarded from a cloned app.
@immutable
class ClonedNotification {
  const ClonedNotification({
    required this.id,
    required this.cloneId,
    required this.cloneName,
    required this.packageName,
    required this.title,
    required this.body,
    required this.receivedAt,
    this.priority = NotificationPriority.normal,
    this.read = false,
  });

  final String id;
  final String cloneId;
  final String cloneName;
  final String packageName;
  final String title;
  final String body;
  final DateTime receivedAt;
  final NotificationPriority priority;
  final bool read;
}

enum NotificationPriority { low, normal, high, urgent }

/// Log entry emitted by the engine, useful for debugging & telemetry.
@immutable
class EngineLog {
  const EngineLog({
    required this.timestamp,
    required this.level,
    required this.component,
    required this.message,
  });

  final DateTime timestamp;
  final EngineLogLevel level;
  final String component;
  final String message;
}

enum EngineLogLevel { debug, info, warning, error }
