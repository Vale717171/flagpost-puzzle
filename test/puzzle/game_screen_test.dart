import 'package:flagpost/puzzle/data/flag_country.dart';
import 'package:flagpost/puzzle/data/flag_repository.dart';
import 'package:flagpost/puzzle/game_screen.dart';
import 'package:flagpost/puzzle/logic/puzzle_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    return _testFlag;
  }

  @override
  FlagCountry dailyFlag({DateTime? utcNow}) {
    return _testFlag;
  }

  FlagCountry get _testFlag => FlagCountry(
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
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('loads without crashing after async flag loading', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GameScreen(
            testEngine: _makeDeterministicEngine(),
            testFlagRepo: fakeFlagRepo,
          ),
        ),
      );

      // Let the async _loadRepository().then(setState) complete
      await tester.pumpAndSettle();

      // If we reach here without exceptions, the screen loaded successfully.
      expect(find.byType(GameScreen), findsOneWidget);
    });

    testWidgets('basic UI elements appear after loading', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GameScreen(
            testEngine: _makeDeterministicEngine(),
            testFlagRepo: fakeFlagRepo,
          ),
        ),
      );
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

    testWidgets('shows Daily Flag label when daily mode is enabled', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GameScreen(
            isDailyFlag: true,
            testEngine: _makeDeterministicEngine(),
            testFlagRepo: fakeFlagRepo,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Daily Flag'), findsOneWidget);
    });

    testWidgets('tapping an adjacent tile increments the move counter', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GameScreen(
            testEngine: _makeDeterministicEngine(),
            testFlagRepo: fakeFlagRepo,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify initial state
      expect(find.text('Moves: 0'), findsOneWidget);

      // Tap tile at position index 7 (value 5, adjacent to empty at index 4).
      // The GestureDetector has key 'puzzle-tile-position-7'.
      final tileFinder = find.byKey(const Key('puzzle-tile-position-7'));
      expect(
        tileFinder,
        findsOneWidget,
        reason: 'Tile at position 7 should exist',
      );

      await tester.tap(tileFinder);
      await tester.pump();

      // Move counter should now be 1
      expect(find.text('Moves: 1'), findsOneWidget);
    });

    testWidgets('shows completion dialog with best records on puzzle solved', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GameScreen(
            testEngine: PuzzleEngine.withTiles(3, [1, 2, 3, 4, 5, 6, 7, 9, 8]),
            testFlagRepo: fakeFlagRepo,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap the tile at index 8 (which is '8') to solve
      final tileFinder = find.byKey(const Key('puzzle-tile-position-8'));
      await tester.tap(tileFinder);

      // Wait for completion logic and dialog to render
      await tester.pumpAndSettle();

      // Dialog should appear
      expect(find.text('Puzzle completed!'), findsOneWidget);
      // 'New best!' should be present (once for time, once for moves)
      expect(find.text('New best!'), findsWidgets);
      // Moves was 1 (appears in game screen and dialog)
      expect(find.text('Moves: 1'), findsWidgets);
      // Best Moves: 1
      expect(find.text('Best Moves: 1'), findsOneWidget);
    });

    testWidgets('difficulty selector shows popup with three options', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GameScreen(
            testEngine: _makeDeterministicEngine(),
            testFlagRepo: fakeFlagRepo,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // The difficulty selector should be visible with default 4x4 label
      // (testEngine is 3x3, but _currentSize defaults to 4 until _startNewGame
      //  is called; after loadAll the game starts with size 4)
      final selector = find.byKey(const Key('difficulty-selector'));
      expect(selector, findsOneWidget);

      // Tap the selector to open the popup menu
      await tester.tap(selector);
      await tester.pumpAndSettle();

      // All three difficulty options should appear
      expect(find.text('Easy 3×3'), findsOneWidget);
      expect(find.text('Medium 4×4'), findsOneWidget);
      expect(find.text('Hard 5×5'), findsOneWidget);
    });

    testWidgets('selecting a difficulty resets moves counter', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GameScreen(
            testEngine: _makeDeterministicEngine(),
            testFlagRepo: fakeFlagRepo,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Make a move first
      final tileFinder = find.byKey(const Key('puzzle-tile-position-7'));
      await tester.tap(tileFinder);
      await tester.pump();
      expect(find.text('Moves: 1'), findsOneWidget);

      // Open difficulty selector and pick Easy 3x3
      final selector = find.byKey(const Key('difficulty-selector'));
      await tester.tap(selector);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Easy 3×3'));
      await tester.pumpAndSettle();

      // Moves should be reset to 0
      expect(find.text('Moves: 0'), findsOneWidget);
    });

    testWidgets('selecting Easy 3x3 updates selector label and board size', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: GameScreen(testFlagRepo: fakeFlagRepo)),
      );
      await tester.pumpAndSettle();

      // Default difficulty label should be 4×4
      expect(find.text('4×4'), findsOneWidget);

      // Open difficulty selector
      final selector = find.byKey(const Key('difficulty-selector'));
      await tester.tap(selector);
      await tester.pumpAndSettle();

      // Select Easy 3×3
      await tester.tap(find.text('Easy 3×3'));
      await tester.pumpAndSettle();

      // Selector label should now show 3×3
      expect(find.text('3×3'), findsOneWidget);
      // Old label should be gone
      expect(find.text('4×4'), findsNothing);

      // Board should have 9 tile widgets (8 numbered + 1 empty)
      // The puzzle-tile-position keys go from 0..8 for a 3x3 grid
      expect(find.byKey(const Key('puzzle-tile-position-8')), findsOneWidget);
      // Index 9 should NOT exist (that would be a 4x4+ grid)
      expect(find.byKey(const Key('puzzle-tile-position-9')), findsNothing);
    });

    testWidgets('selecting Hard 5x5 updates selector label', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: GameScreen(testFlagRepo: fakeFlagRepo)),
      );
      await tester.pumpAndSettle();

      // Open difficulty selector
      final selector = find.byKey(const Key('difficulty-selector'));
      await tester.tap(selector);
      await tester.pumpAndSettle();

      // Select Hard 5×5
      await tester.tap(find.text('Hard 5×5'));
      await tester.pumpAndSettle();

      // Selector label should now show 5×5
      expect(find.text('5×5'), findsOneWidget);
      expect(find.text('4×4'), findsNothing);

      // Board should have 25 tile widgets (24 numbered + 1 empty)
      expect(find.byKey(const Key('puzzle-tile-position-24')), findsOneWidget);
      // Index 25 should NOT exist
      expect(find.byKey(const Key('puzzle-tile-position-25')), findsNothing);
    });
  });
}
