import 'package:flagpost/puzzle/data/flag_country.dart';
import 'package:flagpost/puzzle/data/flag_repository.dart';
import 'package:flagpost/puzzle/home_screen.dart';
import 'package:flagpost/puzzle/settings/puzzle_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeHomeFlagRepository extends FlagRepository {
  FakeHomeFlagRepository(List<FlagCountry> flags) : super(initialFlags: flags);

  @override
  Future<void> loadAll() async {
    // no-op for tests
  }
}

void main() {
  group('HomeScreen progress summary', () {
    late FakeHomeFlagRepository repo;

    setUp(() {
      repo = FakeHomeFlagRepository([
        FlagCountry(
          id: 'it',
          countryName: 'Italy',
          capital: 'Rome',
          continent: 'Europe',
          assetPath: 'assets/flags/images/it.png',
          shortFact: 'Fact IT',
        ),
        FlagCountry(
          id: 'fr',
          countryName: 'France',
          capital: 'Paris',
          continent: 'Europe',
          assetPath: 'assets/flags/images/fr.png',
          shortFact: 'Fact FR',
        ),
      ]);
    });

    testWidgets('shows solved/total and streak when available', (
      WidgetTester tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        'best_time_it_4': 55,
        PuzzlePreferences.dailyStreakCountKey: 3,
      });
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(testFlagRepo: repo, testPrefs: prefs),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('home-progress-summary')), findsOneWidget);
      expect(find.text('Solved: 1/2'), findsOneWidget);
      expect(find.text('Daily streak: 3'), findsOneWidget);
    });

    testWidgets('hides streak row when streak is zero', (
      WidgetTester tester,
    ) async {
      SharedPreferences.setMockInitialValues({'best_time_it_4': 55});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(testFlagRepo: repo, testPrefs: prefs),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Solved: 1/2'), findsOneWidget);
      expect(find.byKey(const Key('home-daily-streak')), findsNothing);
    });
  });
}
