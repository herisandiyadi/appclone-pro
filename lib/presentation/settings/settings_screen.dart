import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/providers.dart';
import '../../core/security/security_manager.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _pinController = TextEditingController();

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final security = ref.read(securityManagerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionHeader('Appearance'),
          _SettingsTile(
            icon: Icons.dark_mode_outlined,
            title: 'Dark Mode',
            trailing: Switch(
              value: themeMode == ThemeMode.dark,
              activeThumbColor: AppColors.accent,
              onChanged: (v) => ref.read(themeModeProvider.notifier).state =
                  v ? ThemeMode.dark : ThemeMode.light,
            ),
          ),
          const SizedBox(height: 16),
          _SectionHeader('Security'),
          _SettingsTile(
            icon: Icons.lock_outline,
            title: security.isPinSet ? 'Change PIN' : 'Set PIN',
            onTap: () => _showSetPin(context, security),
          ),
          _SettingsTile(
            icon: Icons.fingerprint,
            title: 'Biometric Lock',
            trailing: Switch(
              value: security.biometricEnabled,
              activeThumbColor: AppColors.accent,
              onChanged: (v) async {
                if (v) {
                  final ok = await security.authenticateBiometric(
                      reason: 'Enable biometric lock for AppClone Pro');
                  if (!ok) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Biometric not enrolled or failed.')));
                    }
                    return;
                  }
                }
                security.setBiometric(v);
                setState(() {});
              },
            ),
          ),
          const SizedBox(height: 16),
          _SectionHeader('Storage'),
          _SettingsTile(
            icon: Icons.cleaning_services_outlined,
            title: 'Clear Clone Cache',
            onTap: () => ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('Cache cleared.'))),
          ),
          const SizedBox(height: 16),
          _SectionHeader('About'),
          _SettingsTile(
            icon: Icons.info_outline,
            title: 'Version',
            trailing: const Text('v0.1.0',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }

  void _showSetPin(BuildContext context, SecurityManager security) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Set PIN'),
        content: TextField(
          controller: _pinController,
          obscureText: true,
          maxLength: 6,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: '4-6 digit PIN'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (_pinController.text.length >= 4) {
                security.setPin(_pinController.text);
                _pinController.clear();
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('PIN set successfully.')));
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.1,
                )),
      );
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: ListTile(
            leading: Icon(icon, color: AppColors.textSecondary),
            title: Text(title),
            trailing: trailing,
            onTap: onTap,
          ),
        ),
      );
}
