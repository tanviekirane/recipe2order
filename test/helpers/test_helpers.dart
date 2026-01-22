import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Wraps a widget in MaterialApp for testing
Widget createTestableWidget(Widget child) {
  return MaterialApp(
    home: child,
  );
}

/// Wraps a widget in MaterialApp with a Scaffold for testing
Widget createTestableWidgetWithScaffold(Widget child) {
  return MaterialApp(
    home: Scaffold(body: child),
  );
}

/// Pumps widget and settles all animations
Future<void> pumpAndSettle(WidgetTester tester, Widget widget) async {
  await tester.pumpWidget(createTestableWidget(widget));
  await tester.pumpAndSettle();
}
