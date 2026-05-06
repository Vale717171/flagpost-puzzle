import 'package:flagpost/puzzle/collection_screen.dart';
import 'package:flagpost/puzzle/data/flag_country.dart';
import 'package:flagpost/puzzle/data/flag_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeCollectionFlagRepository extends FlagRepository {
  FakeCollectionFlagRepository(List<FlagCountry> flags)
    : super(initialFlags: flags);

  @override
  Future<void> loadAll() async {
    // no-op in tests
  }
}

void main() {
  group('CollectionScreen', () {
    late FakeCollectionFlagRepository repo;

    setUp(() {
      repo = FakeCollectionFlagRepository([
        FlagCountry(
          id: 'it',
          countryName: 'Italy',
          capital: 'Rome',
          continent: 'Europe',
          assetPath: 'assets/flags/images/it.png',
          shortFact: 'Test fact IT',
        ),
        FlagCountry(
          id: 'fr',
          countryName: 'France',
          capital: 'Paris',
          continent: 'Europe',
          assetPath: 'assets/flags/images/fr.png',
          shortFact: 'Test fact FR',
        ),
      ]);
    });

    testWidgets('shows solved and unsolved states from local records', (
      WidgetTester tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        'best_time_it_4': 60,
        'best_moves_it_4': 30,
        'best_stars_it_4': 2,
      });
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        MaterialApp(
          home: CollectionScreen(testFlagRepo: repo, testPrefs: prefs),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('collection-item-it')), findsOneWidget);
      expect(find.byKey(const Key('collection-item-fr')), findsOneWidget);
      expect(find.text('Unsolved'), findsWidgets);
    });

    testWidgets('tapping solved flag opens detail dialog', (
      WidgetTester tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        'best_time_it_4': 60,
        'best_moves_it_4': 30,
        'best_stars_it_4': 3,
      });
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        MaterialApp(
          home: CollectionScreen(testFlagRepo: repo, testPrefs: prefs),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('collection-item-it')));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Italy'),
        ),
        findsOneWidget,
      );
      expect(find.text('Capital: Rome'), findsOneWidget);
      expect(find.text('Best Moves: 30'), findsOneWidget);
    });

    testWidgets('tapping unsolved flag shows unlock message', (
      WidgetTester tester,
    ) async {
      SharedPreferences.setMockInitialValues({'best_time_it_4': 60});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        MaterialApp(
          home: CollectionScreen(testFlagRepo: repo, testPrefs: prefs),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('collection-item-fr')));
      await tester.pump();

      expect(find.text('Solve this flag to unlock details.'), findsOneWidget);
    });

    testWidgets('filter chips show all, solved, and unsolved subsets', (
      WidgetTester tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        'best_time_it_4': 60,
        'best_moves_it_4': 30,
        'best_stars_it_4': 2,
      });
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        MaterialApp(
          home: CollectionScreen(testFlagRepo: repo, testPrefs: prefs),
        ),
      );
      await tester.pumpAndSettle();

      // All
      expect(find.byKey(const Key('collection-item-it')), findsOneWidget);
      expect(find.byKey(const Key('collection-item-fr')), findsOneWidget);

      // Solved
      await tester.tap(find.byKey(const Key('filter-solved')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('collection-item-it')), findsOneWidget);
      expect(find.byKey(const Key('collection-item-fr')), findsNothing);

      // Unsolved
      await tester.tap(find.byKey(const Key('filter-unsolved')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('collection-item-it')), findsNothing);
      expect(find.byKey(const Key('collection-item-fr')), findsOneWidget);
    });
  });
}
