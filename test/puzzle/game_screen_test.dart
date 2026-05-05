import 'package:flagpost/puzzle/game_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('GameScreen loads correctly and displays basic UI',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: GameScreen(),
    ));

    expect(find.text('Play'), findsOneWidget);
    expect(find.text('Restart'), findsOneWidget);
    expect(find.text('Preview'), findsOneWidget);

    // Initial moves counter should be 0
    expect(find.text('Moves: 0'), findsOneWidget);
  });

  testWidgets('Tapping adjacent tile moves it and increments move counter',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: GameScreen(),
    ));

    // Tap all AnimatedPositioned children containing a GestureDetector
    final gestureDetectors = find.descendant(
      of: find.byType(AnimatedPositioned),
      matching: find.byType(GestureDetector),
    );
    final count = tester.widgetList(gestureDetectors).length;
    
    for (int i = 0; i < count; i++) {
      await tester.tap(gestureDetectors.at(i));
      // Pump a short duration to allow setState to run, but not full settle since timer is periodic
      await tester.pump(const Duration(milliseconds: 50));
    }
    
    // Check if move counter incremented. It should be at least 1.
    final movesTextFinder = find.byWidgetPredicate((widget) {
      if (widget is Text) {
        final data = widget.data;
        if (data != null && data.startsWith('Moves: ')) {
          final moves = int.tryParse(data.substring(7));
          return moves != null && moves > 0;
        }
      }
      return false;
    });

    expect(movesTextFinder, findsOneWidget, reason: 'Moves counter should be > 0 after tapping all tiles');
  });
}
