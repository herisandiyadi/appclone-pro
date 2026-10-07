import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/providers.dart';
import '../../data/model/clone_app.dart';
import '../cloning/clone_app_window_screen.dart';
import '../security/isolated_session_screen.dart';
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
    // Offer launch mode: isolated second-account web session vs native app task
    final mode = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('How to open?', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
            ListTile(
              leading: const Icon(Icons.person_add_alt_1, color: Color(0xFF00F0FF)),
              title: const Text('Account 2 — Isolated Session'),
              subtitle: const Text('Separate login profile (second account)'),
              onTap: () => Navigator.pop(ctx, 'isolated'),
            ),
            ListTile(
              leading: const Icon(Icons.open_in_new),
              title: const Text('Open Native App'),
              subtitle: const Text('Launch the installed app'),
              onTap: () => Navigator.pop(ctx, 'native'),
            ),
          ],
        ),
      ),
    );
    if (mode == null || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    if (mode == 'isolated') {
      navigator.push(
        MaterialPageRoute(builder: (_) => IsolatedSessionScreen(clone: clone)),
      );
      return;
    }

    final bridge = ref.read(nativeBridgeProvider);
    final engine = ref.read(cloningEngineProvider);

    // Try to launch the REAL installed app via Android Intent
    final launched = await bridge.launchApp(clone.packageName);
    if (!context.mounted) return;

    if (launched) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Opened ${clone.displayName}'),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
    } else {
      // App not installed on device: open the instance window so user gets clear feedback
      final process = await engine.launchClone(clone);
      if (!context.mounted) return;
      if (process != null) {
        navigator.push(
          MaterialPageRoute(
            builder: (_) => CloneAppWindowScreen(clone: clone, process: process),
          ),
        );
      } else {
        messenger.showSnackBar(
          SnackBar(
            content: Text('${clone.displayName} is not installed on this device.'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
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
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Rename'),
              onTap: () {
                Navigator.pop(ctx);
                _showRenameDialog(context, ref, clone);
              },
            ),
            ListTile(
              leading: const Icon(Icons.color_lens_outlined),
              title: const Text('Change Icon'),
              onTap: () {
                Navigator.pop(ctx);
                _showChangeIconDialog(context, ref, clone);
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

  void _showRenameDialog(BuildContext context, WidgetRef ref, CloneApp clone) {
    final controller = TextEditingController(text: clone.displayName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename Clone'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'New name'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                ref.read(clonesListProvider.notifier).renameClone(clone.id, controller.text.trim());
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showChangeIconDialog(BuildContext context, WidgetRef ref, CloneApp clone) {
    const colors = [
      Color(0xFF00F0FF), Color(0xFFEF4444), Color(0xFF10B981),
      Color(0xFFF59E0B), Color(0xFF8B5CF6), Color(0xFFEC4899),
      Color(0xFF3B82F6), Color(0xFF64748B),
    ];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Change Icon Color'),
        content: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final color in colors)
              GestureDetector(
                onTap: () {
                  ref.read(clonesListProvider.notifier).changeIconColor(clone.id, color.toARGB32());
                  Navigator.pop(ctx);
                },
                child: CircleAvatar(backgroundColor: color, radius: 20),
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
