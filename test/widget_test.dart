import 'package:flutter_test/flutter_test.dart';

import 'package:recipe2order/main.dart';

void main() {
  testWidgets('App shell renders with bottom navigation', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Wait for async operations to complete
    await tester.pumpAndSettle();

    // Verify that the app title appears
    expect(find.text('Recipe2Order'), findsWidgets);

    // Verify bottom navigation bar exists with all destinations
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Recipes'), findsOneWidget);
    expect(find.text('Lists'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('Navigation between tabs works', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Initially on Home screen - should see welcome text
    expect(find.text('Welcome to'), findsOneWidget);

    // Tap on Recipes tab
    await tester.tap(find.text('Recipes'));
    await tester.pumpAndSettle();

    // Should see Recipes screen
    expect(find.text('My Recipes'), findsOneWidget);
    expect(find.text('No recipes yet'), findsOneWidget);

    // Tap on Lists tab
    await tester.tap(find.text('Lists'));
    await tester.pumpAndSettle();

    // Should see Shopping Lists screen
    expect(find.text('Shopping Lists'), findsOneWidget);
    expect(find.text('No shopping lists yet'), findsOneWidget);

    // Tap on Settings tab
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    // Should see Settings screen
    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('Theme'), findsOneWidget);
  });

  testWidgets('Home screen quick action cards navigate correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Tap on Add Recipe card
    await tester.tap(find.text('Add Recipe'));
    await tester.pumpAndSettle();

    // Should navigate to Recipes tab
    expect(find.text('My Recipes'), findsOneWidget);
  });
}
