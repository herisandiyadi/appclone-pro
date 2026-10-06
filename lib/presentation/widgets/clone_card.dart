import 'package:flutter/material.dart';

import '../../core/engine/engine_models.dart';
import '../../data/model/clone_app.dart';

class CloneCard extends StatelessWidget {
  const CloneCard({
    super.key,
    required this.clone,
    required this.isRunning,
    required this.onTap,
    required this.onLongPress,
  });

  final CloneApp clone;
  final bool isRunning;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isRunning
                ? theme.colorScheme.primary.withOpacity(0.5)
                : theme.dividerColor,
          ),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Color(clone.appIconColor).withOpacity(0.18),
                  child: Icon(Icons.apps, color: Color(clone.appIconColor), size: 24),
                ),
                if (clone.locked)
                  const Positioned(
                    right: 0,
                    bottom: 0,
                    child: Icon(Icons.lock, size: 14, color: Colors.orange),
                  ),
                if (isRunning)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 10, height: 10,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        shape: BoxShape.circle,
                        border: Border.all(color: theme.scaffoldBackgroundColor, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              clone.displayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              _formatSize(clone.storageBytes),
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  String _formatSize(int bytes) {
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(0)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
