import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:odometer_poc/home_page.dart';

void main() {
  testWidgets('warns and disables scanning when API key is missing', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: HomePage(apiKey: '', model: 'm'),
      ),
    );

    expect(find.text('Gemini API key missing'), findsOneWidget);
    final fab = tester.widget<FloatingActionButton>(
      find.byType(FloatingActionButton),
    );
    expect(fab.onPressed, isNull);
  });
}
