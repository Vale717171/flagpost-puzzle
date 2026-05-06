class StarThreshold {
  final int threeStarMovesMax;
  final int twoStarMovesMax;
  final int threeStarSecondsMax;
  final int twoStarSecondsMax;

  const StarThreshold({
    required this.threeStarMovesMax,
    required this.twoStarMovesMax,
    required this.threeStarSecondsMax,
    required this.twoStarSecondsMax,
  });
}

class StarRating {
  static const Map<int, StarThreshold> _thresholdsByGridSize = {
    3: StarThreshold(
      threeStarMovesMax: 20,
      twoStarMovesMax: 40,
      threeStarSecondsMax: 90,
      twoStarSecondsMax: 180,
    ),
    4: StarThreshold(
      threeStarMovesMax: 80,
      twoStarMovesMax: 140,
      threeStarSecondsMax: 300,
      twoStarSecondsMax: 480,
    ),
    5: StarThreshold(
      threeStarMovesMax: 200,
      twoStarMovesMax: 350,
      threeStarSecondsMax: 600,
      twoStarSecondsMax: 900,
    ),
  };

  static int calculate({
    required int gridSize,
    required int moves,
    required int seconds,
  }) {
    final threshold = _thresholdsByGridSize[gridSize];
    if (threshold == null) {
      throw ArgumentError('Unsupported grid size for rating: $gridSize');
    }

    final isThreeStar =
        moves <= threshold.threeStarMovesMax &&
        seconds <= threshold.threeStarSecondsMax;
    if (isThreeStar) return 3;

    final isTwoStar =
        moves <= threshold.twoStarMovesMax &&
        seconds <= threshold.twoStarSecondsMax;
    if (isTwoStar) return 2;

    return 1;
  }

  static bool isNewBest({
    required int currentStars,
    required int? previousBestStars,
  }) {
    return previousBestStars == null || currentStars > previousBestStars;
  }
}
