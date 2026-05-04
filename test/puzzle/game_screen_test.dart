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
}
