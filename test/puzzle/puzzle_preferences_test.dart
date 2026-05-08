import 'package:flagpost/puzzle/settings/puzzle_preferences.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PuzzlePreferences', () {
    test('generates legacy progress keys unchanged', () {
      expect(PuzzlePreferences.bestTimeKey('it', 4), 'best_time_it_4');
      expect(PuzzlePreferences.bestMovesKey('it', 4), 'best_moves_it_4');
      expect(PuzzlePreferences.bestStarsKey('it', 4), 'best_stars_it_4');
    });

    test('exposes progress key prefixes for reset logic', () {
      expect(
        PuzzlePreferences.progressKeyPrefixes,
        const ['best_time_', 'best_moves_', 'best_stars_'],
      );
    });
  });
}
