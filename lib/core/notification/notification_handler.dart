/// NotificationHandler — intercepts & forwards notifications per clone.
library;

import 'dart:async';
import 'dart:math';
import 'package:uuid/uuid.dart';

import '../engine/engine_models.dart';

class NotificationHandler {
  NotificationHandler._();
  static final instance = NotificationHandler._();

  final _controller = StreamController<ClonedNotification>.broadcast();
  final List<ClonedNotification> _history = [];
  final _uuid = const Uuid();

  Stream<ClonedNotification> get stream => _controller.stream;
  List<ClonedNotification> get history => List.unmodifiable(_history);

  List<ClonedNotification> forClone(String cloneId) =>
      _history.where((n) => n.cloneId == cloneId).toList();

  int unreadCount(String cloneId) =>
      _history.where((n) => n.cloneId == cloneId && !n.read).length;

  /// Simulate an incoming notification from a clone.
  void simulateNotification({
    required String cloneId,
    required String cloneName,
    required String packageName,
    required String title,
    required String body,
    NotificationPriority priority = NotificationPriority.normal,
  }) {
    final notif = ClonedNotification(
      id: _uuid.v4(),
      cloneId: cloneId,
      cloneName: cloneName,
      packageName: packageName,
      title: title,
      body: body,
      receivedAt: DateTime.now(),
      priority: priority,
    );
    _history.add(notif);
    if (!_controller.isClosed) _controller.add(notif);
  }

  void markRead(String notificationId) {
    final idx = _history.indexWhere((n) => n.id == notificationId);
    if (idx != -1) {
      _history[idx] = ClonedNotification(
        id: _history[idx].id,
        cloneId: _history[idx].cloneId,
        cloneName: _history[idx].cloneName,
        packageName: _history[idx].packageName,
        title: _history[idx].title,
        body: _history[idx].body,
        receivedAt: _history[idx].receivedAt,
        priority: _history[idx].priority,
        read: true,
      );
    }
  }

  void markAllRead(String cloneId) {
    for (var i = 0; i < _history.length; i++) {
      final n = _history[i];
      if (n.cloneId == cloneId && !n.read) {
        _history[i] = ClonedNotification(
          id: n.id, cloneId: n.cloneId, cloneName: n.cloneName,
          packageName: n.packageName, title: n.title, body: n.body,
          receivedAt: n.receivedAt, priority: n.priority, read: true,
        );
      }
    }
  }

  void dispose() => _controller.close();
}
