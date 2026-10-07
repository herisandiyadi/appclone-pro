import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/providers.dart';
import '../../data/model/clone_app.dart';
import '../../data/model/installed_app.dart';
import '../../presentation/theme/app_theme.dart';
import '../cloning/cloning_progress_screen.dart';

class AppSelectScreen extends ConsumerStatefulWidget {
  const AppSelectScreen({super.key});

  @override
  ConsumerState<AppSelectScreen> createState() => _AppSelectScreenState();
}

class _AppSelectScreenState extends ConsumerState<AppSelectScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final apps = ref.watch(installedAppsProvider)
        .where((a) => a.appName.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Clone an App')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search installed apps...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: apps.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (ctx, i) => _AppRow(app: apps[i]),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppRow extends ConsumerWidget {
  const _AppRow({required this.app});
  final InstalledApp app;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: AppColors.accent.withValues(alpha: 0.12),
            child: Icon(app.icon, color: AppColors.accent),
          ),
          title: Text(app.appName),
          subtitle: Text(_fmtSize(app.sizeBytes), style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          trailing: FilledButton.tonal(
            onPressed: app.isClonable ? () => _startClone(context, ref) : null,
            child: const Text('Clone'),
          ),
        ),
      ),
    );
  }

  void _startClone(BuildContext context, WidgetRef ref) {
    final clone = CloneApp.create(
      packageName: app.packageName,
      displayName: '${app.appName} Clone',
      appIconColor: AppColors.accent.toARGB32(),
    );
    ref.read(clonesListProvider.notifier).addClone(clone);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => CloningProgressScreen(clone: clone)),
    );
  }

  String _fmtSize(int bytes) {
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(0)} MB';
  }
}
