import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/providers.dart';
import '../../data/model/clone_app.dart';
import '../widgets/clone_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clones = ref.watch(clonesListProvider).where((c) => !c.hidden).toList();
    final engine = ref.watch(cloningEngineProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AppClone Pro'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => _showNotifications(context, ref),
          ),
        ],
      ),
      body: clones.isEmpty
          ? _EmptyState()
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.78,
              ),
              itemCount: clones.length,
              itemBuilder: (context, i) => CloneCard(
                clone: clones[i],
                isRunning: engine.isRunning(clones[i].id),
                onTap: () => _onCloneTap(context, ref, clones[i]),
                onLongPress: () => _showCloneActions(context, ref, clones[i]),
              ),
            ),
    );
  }

  void _onCloneTap(BuildContext context, WidgetRef ref, CloneApp clone) async {
    if (clone.locked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"${clone.displayName}" is locked. Unlock in Settings.')),
      );
      return;
    }
    final engine = ref.read(cloningEngineProvider);
    final messenger = ScaffoldMessenger.of(context);
    final process = await engine.launchClone(clone.id);
    if (process != null) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Launching ${clone.displayName} (pid ${process.pid}, ${process.memoryMb}MB)'),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
    }
  }

  void _showCloneActions(BuildContext context, WidgetRef ref, CloneApp clone) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(clone.locked ? Icons.lock_open : Icons.lock_outline),
              title: Text(clone.locked ? 'Unlock' : 'Lock'),
              onTap: () {
                ref.read(clonesListProvider.notifier).toggleLock(clone.id);
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: Icon(clone.hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined),
              title: Text(clone.hidden ? 'Unhide' : 'Hide'),
              onTap: () {
                ref.read(clonesListProvider.notifier).toggleHide(clone.id);
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Color(0xFFEF4444)),
              title: const Text('Delete', style: TextStyle(color: Color(0xFFEF4444))),
              onTap: () {
                ref.read(clonesListProvider.notifier).removeClone(clone.id);
                ref.read(cloningEngineProvider).removeClone(clone.id);
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showNotifications(BuildContext context, WidgetRef ref) {
    final handler = ref.read(notificationHandlerProvider);
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Notifications', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
            if (handler.history.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text('No notifications yet.', textAlign: TextAlign.center),
              )
            else
              ...handler.history.map((n) => ListTile(
                    leading: const Icon(Icons.notifications),
                    title: Text('${n.cloneName}: ${n.title}'),
                    subtitle: Text(n.body),
                    trailing: Text(
                      '${n.receivedAt.hour}:${n.receivedAt.minute.toString().padLeft(2, '0')}',
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.apps, size: 64, color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          Text('No clones yet', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text('Tap "Add" to clone your first app.', style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
