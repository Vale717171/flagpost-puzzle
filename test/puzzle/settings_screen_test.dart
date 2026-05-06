import 'package:flagpost/puzzle/settings/puzzle_preferences.dart';
import 'package:flagpost/puzzle/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('PuzzleSettingsScreen', () {
    testWidgets('sound toggle defaults to enabled when unset', (
      WidgetTester tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        MaterialApp(home: PuzzleSettingsScreen(testPrefs: prefs)),
      );
      await tester.pumpAndSettle();

      final soundSwitch = tester.widget<Switch>(
        find.descendant(
          of: find.byKey(const Key('sound-toggle')),
          matching: find.byType(Switch),
        ),
      );
      expect(soundSwitch.value, isTrue);
    });

    testWidgets('sound toggle persists new value locally', (
      WidgetTester tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        PuzzlePreferences.soundEnabledKey: true,
      });
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        MaterialApp(home: PuzzleSettingsScreen(testPrefs: prefs)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('sound-toggle')));
      await tester.pumpAndSettle();

      expect(prefs.getBool(PuzzlePreferences.soundEnabledKey), isFalse);
    });
  });
}
