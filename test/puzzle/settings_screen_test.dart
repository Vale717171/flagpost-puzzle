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

    testWidgets('renders support section', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        MaterialApp(home: PuzzleSettingsScreen(testPrefs: prefs)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Support the project'), findsOneWidget);
      expect(
        find.text(
          'If you enjoy FlagPost: Puzzle, you can support development.',
        ),
        findsOneWidget,
      );
      expect(find.text('Buy me a coffee'), findsOneWidget);
      expect(find.byIcon(Icons.coffee_outlined), findsOneWidget);
    });

    testWidgets('tapping support tile attempts to open external URL', (
      WidgetTester tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      Uri? launchedUri;

      await tester.pumpWidget(
        MaterialApp(
          home: PuzzleSettingsScreen(
            testPrefs: prefs,
            launchExternalUrl: (uri) async {
              launchedUri = uri;
              return true;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('support-project-tile')));
      await tester.pumpAndSettle();

      expect(launchedUri, PuzzleSettingsScreen.supportUri);
    });

    testWidgets('reset progress clears only progress and streak keys', (
      WidgetTester tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        PuzzlePreferences.soundEnabledKey: true,
        'best_time_it_4': 60,
        'best_moves_it_4': 20,
        'best_stars_it_4': 3,
        PuzzlePreferences.dailyStreakCountKey: 4,
        PuzzlePreferences.dailyStreakLastCompletedDayKey: '2026-05-06',
        'unrelated_key': 'keep-me',
      });
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        MaterialApp(home: PuzzleSettingsScreen(testPrefs: prefs)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('reset-progress-tile')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reset'));
      await tester.pumpAndSettle();

      expect(prefs.getInt('best_time_it_4'), isNull);
      expect(prefs.getInt('best_moves_it_4'), isNull);
      expect(prefs.getInt('best_stars_it_4'), isNull);
      expect(prefs.getInt(PuzzlePreferences.dailyStreakCountKey), isNull);
      expect(
        prefs.getString(PuzzlePreferences.dailyStreakLastCompletedDayKey),
        isNull,
      );
      expect(prefs.getBool(PuzzlePreferences.soundEnabledKey), isTrue);
      expect(prefs.getString('unrelated_key'), 'keep-me');
    });
  });
}
