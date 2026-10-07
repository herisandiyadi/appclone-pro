import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../data/model/clone_app.dart';
import '../theme/app_theme.dart';

/// Isolated web session per clone — a real second login surface
/// backed by a WebView whose cookies/localStorage are isolated per cloneId.
class IsolatedSessionScreen extends StatefulWidget {
  const IsolatedSessionScreen({super.key, required this.clone});

  final CloneApp clone;

  /// Web (second-account) entry points per package.
  static const _webApps = {
    'com.whatsapp': 'https://web.whatsapp.com',
    'com.telegram.messenger': 'https://web.telegram.org/k/',
    'com.instagram.android': 'https://www.instagram.com',
    'com.facebook.katana': 'https://www.facebook.com',
    'com.twitter.android': 'https://x.com',
    'com.zhiliaoapp.musically': 'https://www.tiktok.com',
    'com.linkedin.android': 'https://www.linkedin.com',
  };

  @override
  State<IsolatedSessionScreen> createState() => _IsolatedSessionScreenState();
}

class _IsolatedSessionScreenState extends State<IsolatedSessionScreen> {
  late final WebViewController _controller;
  late final String _url;
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _url = IsolatedSessionScreen._webApps[widget.clone.packageName] ?? 'https://www.google.com';
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (value) {
            if (mounted) setState(() => _progress = value / 100);
          },
        ),
      )
      ..loadRequest(Uri.parse(_url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.clone.displayName} — Account 2'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reload',
            onPressed: () => _controller.reload(),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.danger),
            tooltip: 'Clear session data',
            onPressed: () async {
              await _controller.clearLocalStorage();
              await _controller.runJavaScript('document.cookie.split(";").forEach(c => document.cookie = c.trim().split("=")[0] + "=;expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;");');
              await _controller.reload();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Session data cleared.')),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_progress < 1.0)
            LinearProgressIndicator(value: _progress, backgroundColor: AppColors.surface),
          Expanded(child: WebViewWidget(controller: _controller)),
        ],
      ),
    );
  }
}

/// Helper used by the dashboard to resolve the web entry URL for a clone.
String webAppUrlFor(String packageName) {
  return IsolatedSessionScreen._webApps[packageName] ??
      'https://www.google.com/search?q=${Uri.encodeComponent(packageName)}';
}
