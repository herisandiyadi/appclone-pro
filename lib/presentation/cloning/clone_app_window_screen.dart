import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/providers.dart';
import '../../core/engine/engine_models.dart';
import '../../data/model/clone_app.dart';
import '../theme/app_theme.dart';

/// Simulated app window for a running clone instance.
/// Real native app execution requires the native cloning engine (next phase).
class CloneAppWindowScreen extends ConsumerStatefulWidget {
  const CloneAppWindowScreen({super.key, required this.clone, required this.process});

  final CloneApp clone;
  final VirtualProcess process;

  @override
  ConsumerState<CloneAppWindowScreen> createState() => _CloneAppWindowScreenState();
}

class _CloneAppWindowScreenState extends ConsumerState<CloneAppWindowScreen> {
  late VirtualProcess _process;

  @override
  void initState() {
    super.initState();
    _process = widget.process;
  }

  Future<void> _stopInstance() async {
    await ref.read(cloningEngineProvider).killClone(widget.clone.id);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.clone.displayName),
        actions: [
          IconButton(
            icon: const Icon(Icons.stop_circle_outlined, color: AppColors.danger),
            tooltip: 'Stop instance',
            onPressed: _stopInstance,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppColors.surface,
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Running in virtual container • pid ${_process.pid} • ${_process.memoryMb}MB',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Color(widget.clone.appIconColor).withValues(alpha: 0.18),
                      child: Icon(Icons.apps, size: 40, color: Color(widget.clone.appIconColor)),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      widget.clone.displayName,
                      style: theme.textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Instance is running (simulation mode)',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Native app execution requires the native cloning engine.',
                      style: theme.textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.stop),
                      label: const Text('Stop instance'),
                      onPressed: _stopInstance,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
