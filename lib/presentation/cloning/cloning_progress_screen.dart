import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/providers.dart';
import '../../core/engine/cloning_engine.dart';
import '../../core/engine/virtual_container.dart';
import '../../data/model/clone_app.dart';
import '../theme/app_theme.dart';

class CloningProgressScreen extends ConsumerStatefulWidget {
  const CloningProgressScreen({super.key, required this.clone});
  final CloneApp clone;

  @override
  ConsumerState<CloningProgressScreen> createState() => _CloningProgressScreenState();
}

class _CloningProgressScreenState extends ConsumerState<CloningProgressScreen> {
  double _progress = 0;
  String _message = 'Initializing...';
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _runClone();
  }

  Future<void> _runClone() async {
    final engine = ref.read(cloningEngineProvider);
    await for (final event in engine.createClone(widget.clone)) {
      if (mounted) {
        setState(() {
          _progress = event.percent;
          _message = event.message;
          _done = event.step == CloningStep.done;
        });
      }
    }
    // Mark clone as ready
    if (mounted) {
      ref.read(clonesListProvider.notifier).updateClone(
            widget.clone.copyWith(status: CloneStatus.ready),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cloning...')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: _progress,
                      strokeWidth: 8,
                      backgroundColor: AppColors.surfaceHover,
                      valueColor: const AlwaysStoppedAnimation(AppColors.accent),
                    ),
                    Text(
                      '${(_progress * 100).toInt()}%',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: AppColors.accent,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Text(
                widget.clone.displayName,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(_message, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 40),
              if (_done) ...[
                FilledButton.icon(
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Done'),
                  onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
                ),
              ] else
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
