import 'package:flagpost/puzzle/logic/star_rating.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StarRating.calculate', () {
    test('3x3 thresholds are applied deterministically', () {
      expect(StarRating.calculate(gridSize: 3, moves: 20, seconds: 90), 3);
      expect(StarRating.calculate(gridSize: 3, moves: 40, seconds: 180), 2);
      expect(StarRating.calculate(gridSize: 3, moves: 41, seconds: 180), 1);
    });

    test('4x4 thresholds are applied deterministically', () {
      expect(StarRating.calculate(gridSize: 4, moves: 80, seconds: 300), 3);
      expect(StarRating.calculate(gridSize: 4, moves: 140, seconds: 480), 2);
      expect(StarRating.calculate(gridSize: 4, moves: 141, seconds: 480), 1);
    });

    test('5x5 thresholds are applied deterministically', () {
      expect(StarRating.calculate(gridSize: 5, moves: 200, seconds: 600), 3);
      expect(StarRating.calculate(gridSize: 5, moves: 350, seconds: 900), 2);
      expect(StarRating.calculate(gridSize: 5, moves: 351, seconds: 900), 1);
    });
  });

  group('StarRating.isNewBest', () {
    test('returns true when there is no previous best', () {
      expect(
        StarRating.isNewBest(currentStars: 2, previousBestStars: null),
        isTrue,
      );
    });

    test('returns true only when current stars are higher', () {
      expect(
        StarRating.isNewBest(currentStars: 3, previousBestStars: 2),
        isTrue,
      );
      expect(
        StarRating.isNewBest(currentStars: 2, previousBestStars: 2),
        isFalse,
      );
      expect(
        StarRating.isNewBest(currentStars: 1, previousBestStars: 3),
        isFalse,
      );
    });
  });
}
