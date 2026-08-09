// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart' show Size;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart' show Icons;

import 'package:actibind/app.dart';
import 'package:actibind/core/settings/family_mode_controller.dart';
import 'package:actibind/features/home/presentation/pages/home_page.dart';

void main() {
  SharedPreferences.setMockInitialValues({});

  testWidgets('App launches without errors', (WidgetTester tester) async {
    await tester.pumpWidget(const App(home: HomePage()));
    expect(find.byType(App), findsOneWidget);
  });

  testWidgets('Primary navigation stays usable on a narrow screen', (
    WidgetTester tester,
  ) async {
    await FamilyModeController.instance.setEnabled(false);
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const App(home: HomePage()));

    for (final icon in [
      Icons.view_timeline_rounded,
      Icons.insights_rounded,
      Icons.settings_rounded,
    ]) {
      await tester.tap(find.byIcon(icon));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }

    expect(find.byIcon(Icons.family_restroom_rounded), findsOneWidget);
    await tester.tap(find.text('Family mode'));
    await tester.pump();
    expect(find.byIcon(Icons.family_restroom_rounded), findsNWidgets(2));

    await tester.tap(find.byIcon(Icons.family_restroom_rounded).last);
    await tester.pumpAndSettle();
    expect(
      find.text('Manage child profiles, devices, and screen time'),
      findsOneWidget,
    );

    await tester.tap(find.text('Alex'));
    await tester.pumpAndSettle();
    expect(find.text('Overview'), findsOneWidget);
    expect(find.text('Restrictions'), findsWidgets);
    expect(tester.takeException(), isNull);

    await FamilyModeController.instance.setEnabled(false);
  });

  testWidgets('Activity tabs render on a narrow screen', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const App(home: HomePage()));
    await tester.tap(find.byIcon(Icons.view_timeline_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Current Activity'), findsNothing);
    expect(find.text('CURRENT ACTIVITY'), findsOneWidget);

    await tester.tap(find.text('Device Activity'));
    await tester.pumpAndSettle();
    expect(find.text('Schedule Conflicts'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
