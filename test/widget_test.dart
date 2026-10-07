import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:appclone_pro/main.dart';

void main() {
  testWidgets('App boots and shows dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: AppCloneProApp()));
    await tester.pumpAndSettle();
    expect(find.text('AppClone Pro'), findsOneWidget);
  });
}
