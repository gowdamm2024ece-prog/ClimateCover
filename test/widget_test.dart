// test/widget_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gigshield/main.dart';

void main() {
  testWidgets('GigShield smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: GigShieldApp()),
    );
    expect(find.byType(GigShieldApp), findsOneWidget);
  });
}