import 'package:family_biz_finance/auth_wrapper.dart';
import 'package:family_biz_finance/finance_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App starts and loads AuthWrapper', (WidgetTester tester) async {
    // Note: Testing Firebase requires mocking or using a specific test setup.
    // This is a placeholder to show where your feature-based tests go.

    await tester.pumpWidget(const FinanceRoot());

    // Verify that the Material App is created
    expect(find.byType(MaterialApp), findsOneWidget);

    // Verify that the home is the AuthWrapper
    expect(find.byType(AuthWrapper), findsOneWidget);
  });
}
