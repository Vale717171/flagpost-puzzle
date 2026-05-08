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

class _TestNavigatorObserver extends NavigatorObserver {
  int pushCount = 0;
  int popCount = 0;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushCount++;
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    popCount++;
    super.didPop(route, previousRoute);
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

    testWidgets('refreshes summary after returning from collection', (
      WidgetTester tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final observer = _TestNavigatorObserver();

      await tester.pumpWidget(
        MaterialApp(
          navigatorObservers: [observer],
          home: HomeScreen(testFlagRepo: repo, testPrefs: prefs),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Solved: 0/2'), findsOneWidget);

      await tester.tap(find.text('Collection'));
      await tester.pumpAndSettle();

      await prefs.setInt(PuzzlePreferences.bestTimeKey('it', 4), 55);

      Navigator.of(tester.element(find.byType(Scaffold).first)).pop();
      await tester.pumpAndSettle();

      expect(observer.pushCount, greaterThanOrEqualTo(2));
      expect(observer.popCount, greaterThanOrEqualTo(1));
      expect(find.text('Solved: 1/2'), findsOneWidget);
    });

    testWidgets('refreshes summary after returning from game', (
      WidgetTester tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(testFlagRepo: repo, testPrefs: prefs),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Solved: 0/2'), findsOneWidget);

      await tester.tap(find.text('Play Random'));
      await tester.pumpAndSettle();

      await prefs.setInt(PuzzlePreferences.bestTimeKey('it', 4), 42);

      Navigator.of(tester.element(find.byType(Scaffold).first)).pop();
      await tester.pumpAndSettle();

      expect(find.text('Solved: 1/2'), findsOneWidget);
    });
  });
}
