import 'package:flutter/material.dart';

import '../../core/security/security_manager.dart';
import '../../data/model/clone_app.dart';

/// Gate widget — forces PIN verification if the clone is locked.
class SecurityLockScreen extends StatefulWidget {
  const SecurityLockScreen({super.key, required this.clone, required this.onUnlocked});

  final CloneApp clone;
  final VoidCallback onUnlocked;

  @override
  State<SecurityLockScreen> createState() => _SecurityLockScreenState();
}

class _SecurityLockScreenState extends State<SecurityLockScreen> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _verify(SecurityManager security) {
    if (security.verifyPin(_controller.text)) {
      widget.onUnlocked();
    } else {
      setState(() => _error = 'Incorrect PIN');
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final security = SecurityManager.instance;
    return Scaffold(
      appBar: AppBar(title: Text('Unlock ${widget.clone.displayName}')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 64, color: Color(0xFF00F0FF)),
            const SizedBox(height: 24),
            TextField(
              controller: _controller,
              obscureText: true,
              maxLength: 6,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter PIN',
                errorText: _error,
                counterText: '',
              ),
              onSubmitted: (_) => _verify(security),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => _verify(security),
              child: const Text('Unlock'),
            ),
          ],
        ),
      ),
    );
  }
}
