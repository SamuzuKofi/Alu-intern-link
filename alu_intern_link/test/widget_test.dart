// Basic smoke test for the login screen.
//
// We test LoginScreen directly (instead of the full App) because App
// starts from AuthGate, which needs a real Firebase connection to work.
// LoginScreen itself doesn't touch Firebase until the sign-in button is
// pressed, so it's safe to pump on its own.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:alu_intern_link/features/auth/screens/login_screen.dart';

void main() {
  testWidgets('LoginScreen shows the email and password fields', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: LoginScreen()),
      ),
    );

    expect(find.text('ALU Intern Link'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'ALU email'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Password'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Sign in'), findsOneWidget);
  });

  testWidgets('Submitting an empty form shows validation errors', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: LoginScreen()),
      ),
    );

    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign in'));
    await tester.pump();

    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
  });
}
