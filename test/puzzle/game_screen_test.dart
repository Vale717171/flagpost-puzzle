import 'package:flagpost/puzzle/data/flag_country.dart';
import 'package:flagpost/puzzle/data/flag_repository.dart';
import 'package:flagpost/puzzle/game_screen.dart';
import 'package:flagpost/puzzle/logic/puzzle_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// A FlagRepository pre-loaded with a single fake flag.
/// Avoids rootBundle.loadString() which is unavailable in tests.
class FakeFlagRepository extends FlagRepository {
  FakeFlagRepository() {
    // Override loadAll to be a no-op; data is injected below.
  }

  @override
  Future<void> loadAll() async {
    // no-op: data is already set
  }

  @override
  FlagCountry randomFlag() {
    return FlagCountry(
      id: 'test',
      countryName: 'Testland',
      capital: 'Testville',
      continent: 'Testing',
      // Use a 1x1 transparent PNG encoded as base64 would be ideal,
      // but for widget tests we just need a path that doesn't crash
      // Image.asset with a non-existent path won't crash widget tests
      // because the image framework silently handles missing assets in test.
      assetPath: 'assets/flags/images/it.png',
      shortFact: 'A country made for tests.',
    );
  }
}

/// Build a deterministic 3x3 engine that is NOT one move from solved.
///
/// Layout: [1, 2, 3, 4, 9, 6, 7, 5, 8]
///   empty (9) at index 4 (center).
///   Adjacent tiles: index 1 (value 2), index 3 (value 4),
///                   index 5 (value 6), index 7 (value 5).
///   After moving index 7 → empty goes to 7, tile 5 goes to 4.
///   Result: [1, 2, 3, 4, 5, 6, 7, 9, 8] — still not solved.
PuzzleEngine _makeDeterministicEngine() {
  return PuzzleEngine.withTiles(3, [1, 2, 3, 4, 9, 6, 7, 5, 8]);
}

void main() {
  group('GameScreen', () {
    late FakeFlagRepository fakeFlagRepo;

    setUp(() {
      fakeFlagRepo = FakeFlagRepository();
    });

    testWidgets('loads without crashing after async flag loading',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: GameScreen(
          testEngine: _makeDeterministicEngine(),
          testFlagRepo: fakeFlagRepo,
        ),
      ));

      // Let the async _loadRepository().then(setState) complete
      await tester.pumpAndSettle();

      // If we reach here without exceptions, the screen loaded successfully.
      expect(find.byType(GameScreen), findsOneWidget);
    });

    testWidgets('basic UI elements appear after loading',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: GameScreen(
          testEngine: _makeDeterministicEngine(),
          testFlagRepo: fakeFlagRepo,
        ),
      ));
      await tester.pumpAndSettle();

      // AppBar title
      expect(find.text('Play'), findsOneWidget);

      // Action buttons
      expect(find.text('Restart'), findsOneWidget);
      expect(find.text('Preview'), findsOneWidget);

      // Initial moves counter = 0
      expect(find.text('Moves: 0'), findsOneWidget);

      // Timer starts at 00:00
      expect(find.text('Timer: 00:00'), findsOneWidget);
    });

    testWidgets(
        'tapping an adjacent tile increments the move counter',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: GameScreen(
          testEngine: _makeDeterministicEngine(),
          testFlagRepo: fakeFlagRepo,
        ),
      ));
      await tester.pumpAndSettle();

      // Verify initial state
      expect(find.text('Moves: 0'), findsOneWidget);

      // Tap tile at position index 7 (value 5, adjacent to empty at index 4).
      // The GestureDetector has key 'puzzle-tile-position-7'.
      final tileFinder = find.byKey(const Key('puzzle-tile-position-7'));
      expect(tileFinder, findsOneWidget,
          reason: 'Tile at position 7 should exist');

      await tester.tap(tileFinder);
      await tester.pump();

      // Move counter should now be 1
      expect(find.text('Moves: 1'), findsOneWidget);
    });
  });
}
