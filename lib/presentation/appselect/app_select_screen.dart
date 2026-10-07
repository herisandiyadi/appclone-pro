import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/providers.dart';
import '../../data/model/clone_app.dart';
import '../../data/model/installed_app.dart';
import '../theme/app_theme.dart';
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
    final appsAsync = ref.watch(installedAppsProvider);

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
            child: appsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text('Failed to load installed apps: $e'),
              ),
              data: (apps) {
                final filtered = apps
                    .where((a) => a.appName.toLowerCase().contains(_query.toLowerCase()))
                    .toList();
                if (filtered.isEmpty) {
                  return const Center(child: Text('No apps found.'));
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (ctx, i) => _AppRow(app: filtered[i]),
                );
              },
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
          subtitle: Text(app.packageName,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
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
}
