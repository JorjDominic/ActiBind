// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart' show Offset, Size;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart' show Icons, OutlinedButton;

import 'package:actibind/app.dart';
import 'package:actibind/core/settings/family_mode_controller.dart';
import 'package:actibind/core/settings/developer_mode_controller.dart';
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
      Icons.calendar_month_rounded,
      Icons.bar_chart_rounded,
      Icons.settings_rounded,
    ]) {
      await tester.tap(find.byIcon(icon));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }

    expect(find.byIcon(Icons.family_restroom_rounded), findsOneWidget);
    await tester.tap(find.text('Family mode'));
    await tester.pump();
    expect(find.byIcon(Icons.groups_rounded), findsOneWidget);

    await tester.tap(find.byIcon(Icons.groups_rounded));
    await tester.pumpAndSettle();
    expect(
      find.text('Manage child profiles, devices, and screen time'),
      findsOneWidget,
    );

    expect(find.text('Child profiles'), findsOneWidget);
    expect(find.text('Add Child'), findsOneWidget);
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
    await tester.tap(find.byIcon(Icons.calendar_month_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Current Activity'), findsNothing);
    expect(find.text('Planner'), findsNWidgets(2));

    await tester.tap(find.widgetWithText(OutlinedButton, 'Tasks'));
    await tester.pumpAndSettle();
    expect(find.text('Quick tasks'), findsOneWidget);
    expect(find.text('Add Task'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tapAt(const Offset(8, 8));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Device Activity'));
    await tester.pumpAndSettle();
    expect(find.text('Recent Activity'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Developer mode reveals diagnostics navigation', (
    WidgetTester tester,
  ) async {
    await DeveloperModeController.instance.setEnabled(false);
    await tester.pumpWidget(const App(home: HomePage()));
    await tester.tap(find.byIcon(Icons.settings_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Diagnostics'), findsNothing);
    await tester.tap(find.text('Developer mode'));
    await tester.pump();
    expect(find.text('Diagnostics'), findsOneWidget);

    await DeveloperModeController.instance.setEnabled(false);
  });
}
