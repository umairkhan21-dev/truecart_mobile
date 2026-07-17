import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:truecart_mobile/screens/url_input_screen.dart';

void main() {
  testWidgets('URL input screen renders TrueCart home', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: UrlInputScreen()));
    await tester.pumpAndSettle();

    expect(find.text('TrueCart'), findsOneWidget);
  });
}
