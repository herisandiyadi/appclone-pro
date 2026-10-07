import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:appclone_pro/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    const channel = MethodChannel('appclone_pro/native');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'getInstalledApps') {
        return <Map<String, dynamic>>[
          {'packageName': 'com.whatsapp', 'appName': 'WhatsApp'}
        ];
      }
      if (call.method == 'launchApp') return true;
      return null;
    });
  });

  testWidgets('App boots and shows dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: AppCloneProApp()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('AppClone Pro'), findsOneWidget);
  });
}
