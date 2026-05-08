class PuzzlePreferences {
  static const themeModeKey = 'themeMode';
  static const soundEnabledKey = 'puzzle_sound_enabled';
  static const dailyStreakCountKey = 'daily_streak_count';
  static const dailyStreakLastCompletedDayKey = 'daily_streak_last_day_utc';

  static const _bestTimePrefix = 'best_time_';
  static const _bestMovesPrefix = 'best_moves_';
  static const _bestStarsPrefix = 'best_stars_';

  static const progressKeyPrefixes = <String>[
    _bestTimePrefix,
    _bestMovesPrefix,
    _bestStarsPrefix,
  ];

  static String bestTimeKey(String flagId, int gridSize) =>
      '$_bestTimePrefix${flagId}_$gridSize';

  static String bestMovesKey(String flagId, int gridSize) =>
      '$_bestMovesPrefix${flagId}_$gridSize';

  static String bestStarsKey(String flagId, int gridSize) =>
      '$_bestStarsPrefix${flagId}_$gridSize';
}
