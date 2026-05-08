import 'dart:async';

import 'package:flagpost/puzzle/logic/puzzle_engine.dart';
import 'package:flagpost/puzzle/logic/star_rating.dart';
import 'package:flagpost/puzzle/data/flag_repository.dart';
import 'package:flagpost/puzzle/data/flag_country.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'settings/puzzle_preferences.dart';

class GameScreen extends StatefulWidget {
  final PuzzleEngine? testEngine;
  final FlagRepository? testFlagRepo;
  final bool isDailyFlag;
  final DateTime? testDailyUtcNow;
  const GameScreen({
    super.key,
    this.testEngine,
    this.testFlagRepo,
    this.isDailyFlag = false,
    this.testDailyUtcNow,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late PuzzleEngine _engine;
  late final FlagRepository _flagRepo;
  FlagCountry? _currentFlag;
  bool _isRepoLoaded = false;
  int _moves = 0;
  Timer? _timer;
  int _seconds = 0;
  int _currentSize = 4;
  bool _isPlaying = false;
  int _restartCounter = 0;
  int? _draggedTileIndex;
  double _dragOffset = 0.0;
  final List<_GameSnapshot> _undoStack = [];
  bool _soundEnabled = true;

  @override
  void initState() {
    super.initState();
    _flagRepo = widget.testFlagRepo ?? FlagRepository();
    _loadRepository();
  }

  Future<void> _loadRepository() async {
    try {
      await _flagRepo.loadAll();
      await _loadSoundSetting();
      setState(() {
        _isRepoLoaded = true;
      });
      _startNewGame(_currentSize);
    } catch (_) {}
  }

  Future<void> _loadSoundSetting() async {
    final prefs = await SharedPreferences.getInstance();
    _soundEnabled = prefs.getBool(PuzzlePreferences.soundEnabledKey) ?? true;
  }

  Future<void> _playMoveSound() async {
    if (!_soundEnabled) return;
    try {
      await SystemSound.play(SystemSoundType.click);
    } catch (_) {}
  }

  Future<void> _playCompletionSound() async {
    if (!_soundEnabled) return;
    try {
      await SystemSound.play(SystemSoundType.alert);
    } catch (_) {}
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startNewGame(int size) {
    _timer?.cancel();
    setState(() {
      if (_isRepoLoaded) {
        _currentFlag = widget.isDailyFlag
            ? _flagRepo.dailyFlag(utcNow: widget.testDailyUtcNow)
            : _flagRepo.randomFlag();
      }
      _currentSize = size;
      if (widget.testEngine != null) {
        _engine = widget.testEngine!;
      } else {
        _engine = PuzzleEngine(size);
        // Determine move count based on size for a good shuffle
        final shuffleMoves = size == 3
            ? 50
            : size == 4
            ? 100
            : 150;
        _engine.shuffle(shuffleMoves);
      }
      _moves = 0;
      _seconds = 0;
      _isPlaying = true;
      _restartCounter++;
      _draggedTileIndex = null;
      _dragOffset = 0.0;
      _undoStack.clear();
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isPlaying) {
        setState(() {
          _seconds++;
        });
      }
    });
  }

  void _onTileTapped(int index) {
    if (!_isPlaying) return;
    if (_draggedTileIndex != null) return; // Ignore tap if currently dragging

    if (_engine.canMove(index)) {
      setState(() {
        _saveUndoSnapshot();
        _engine.move(index);
        _moves++;
        unawaited(_playMoveSound());

        if (_engine.isSolved) {
          _handlePuzzleCompleted();
        }
      });
    }
  }

  void _onPanStart(DragStartDetails details, int index) {
    if (!_isPlaying) return;
    if (_engine.canMove(index)) {
      setState(() {
        _draggedTileIndex = index;
        _dragOffset = 0.0;
      });
    }
  }

  void _onPanUpdate(DragUpdateDetails details, int index) {
    if (_draggedTileIndex != index) return;
    final eIndex = _engine.emptyIndex;
    final row = index ~/ _currentSize;
    final col = index % _currentSize;
    final eRow = eIndex ~/ _currentSize;
    final eCol = eIndex % _currentSize;

    setState(() {
      if (row == eRow) {
        _dragOffset += details.delta.dx;
      } else if (col == eCol) {
        _dragOffset += details.delta.dy;
      }
    });
  }

  void _onPanEnd(DragEndDetails details, int index, double tileSize) {
    if (_draggedTileIndex != index) return;

    final offsetMag = _dragOffset.abs();

    setState(() {
      _draggedTileIndex = null;
      _dragOffset = 0.0;
    });

    if (offsetMag > tileSize * 0.4) {
      if (_engine.canMove(index)) {
        setState(() {
          _saveUndoSnapshot();
          _engine.move(index);
          _moves++;
          unawaited(_playMoveSound());

          if (_engine.isSolved) {
            _handlePuzzleCompleted();
          }
        });
      }
    }
  }

  void _saveUndoSnapshot() {
    _undoStack.add(
      _GameSnapshot(
        gridSize: _engine.size,
        tiles: List<int>.from(_engine.tiles),
        moves: _moves,
        seconds: _seconds,
      ),
    );
  }

  void _undoLastMove() {
    if (_undoStack.isEmpty || !_isPlaying) return;
    final snapshot = _undoStack.removeLast();
    setState(() {
      _engine = PuzzleEngine.withTiles(snapshot.gridSize, snapshot.tiles);
      _currentSize = snapshot.gridSize;
      _moves = snapshot.moves;
      _seconds = snapshot.seconds;
      _draggedTileIndex = null;
      _dragOffset = 0.0;
    });
    unawaited(_playMoveSound());
  }

  Future<void> _handlePuzzleCompleted() async {
    _isPlaying = false;
    _timer?.cancel();
    unawaited(_playCompletionSound());

    final prefs = await SharedPreferences.getInstance();
    final flagId = _currentFlag!.id;
    final timeKey = PuzzlePreferences.bestTimeKey(flagId, _currentSize);
    final movesKey = PuzzlePreferences.bestMovesKey(flagId, _currentSize);
    final starsKey = PuzzlePreferences.bestStarsKey(flagId, _currentSize);

    final bestTime = prefs.getInt(timeKey);
    final bestMoves = prefs.getInt(movesKey);
    final bestStars = prefs.getInt(starsKey);
    final currentStars = StarRating.calculate(
      gridSize: _currentSize,
      moves: _moves,
      seconds: _seconds,
    );

    bool isNewBestTime = false;
    bool isNewBestMoves = false;

    if (bestTime == null || _seconds < bestTime) {
      await prefs.setInt(timeKey, _seconds);
      isNewBestTime = true;
    }
    if (bestMoves == null || _moves < bestMoves) {
      await prefs.setInt(movesKey, _moves);
      isNewBestMoves = true;
    }
    final isNewBestStars = StarRating.isNewBest(
      currentStars: currentStars,
      previousBestStars: bestStars,
    );
    if (isNewBestStars) {
      await prefs.setInt(starsKey, currentStars);
    }
    if (widget.isDailyFlag) {
      await _updateDailyStreak(prefs);
    }

    if (!mounted) return;

    _showCompletionDialog(
      bestTime: isNewBestTime ? _seconds : bestTime ?? _seconds,
      bestMoves: isNewBestMoves ? _moves : bestMoves ?? _moves,
      stars: currentStars,
      bestStars: isNewBestStars ? currentStars : bestStars ?? currentStars,
      isNewBestTime: isNewBestTime,
      isNewBestMoves: isNewBestMoves,
      isNewBestStars: isNewBestStars,
    );
  }

  Future<void> _updateDailyStreak(SharedPreferences prefs) async {
    final nowUtc = (widget.testDailyUtcNow ?? DateTime.now()).toUtc();
    final todayUtc = DateTime.utc(nowUtc.year, nowUtc.month, nowUtc.day);
    final todayKey = _formatUtcDay(todayUtc);

    final lastCompletedDay = prefs.getString(
      PuzzlePreferences.dailyStreakLastCompletedDayKey,
    );
    final currentStreak =
        prefs.getInt(PuzzlePreferences.dailyStreakCountKey) ?? 0;

    if (lastCompletedDay == todayKey) {
      return;
    }

    int newStreak = 1;
    if (lastCompletedDay != null) {
      final parsedLast = DateTime.tryParse(lastCompletedDay);
      if (parsedLast != null) {
        final diffDays = todayUtc.difference(parsedLast).inDays;
        if (diffDays == 1) {
          newStreak = currentStreak + 1;
        }
      }
    }

    await prefs.setInt(PuzzlePreferences.dailyStreakCountKey, newStreak);
    await prefs.setString(
      PuzzlePreferences.dailyStreakLastCompletedDayKey,
      todayKey,
    );
  }

  void _showCompletionDialog({
    required int bestTime,
    required int bestMoves,
    required int stars,
    required int bestStars,
    required bool isNewBestTime,
    required bool isNewBestMoves,
    required bool isNewBestStars,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Puzzle completed!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This Run',
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.timer_outlined, size: 16),
                      const SizedBox(width: 6),
                      Text('Time: ${_formatTime(_seconds)}'),
                      if (isNewBestTime)
                        const Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Text(
                            'New best!',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.swipe_outlined, size: 16),
                      const SizedBox(width: 6),
                      Text('Moves: $_moves'),
                      if (isNewBestMoves)
                        const Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Text(
                            'New best!',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star_border, size: 16),
                      const SizedBox(width: 6),
                      const Text('Rating: '),
                      _buildStars(stars),
                      if (isNewBestStars)
                        const Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Text(
                            'New best!',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Best Records',
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Best Time: ${_formatTime(bestTime)}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    'Best Moves: $bestMoves',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Row(
                    children: [
                      const Text(
                        'Best Stars: ',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      IconTheme(
                        data: const IconThemeData(
                          size: 14,
                          color: Colors.amber,
                        ),
                        child: _buildStars(bestStars),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (_currentFlag != null) ...[
              Text(
                'Country: ${_currentFlag!.countryName}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Capital: ${_currentFlag!.capital}'),
              const SizedBox(height: 8),
              Text(
                _currentFlag!.shortFact,
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Back to home
            },
            child: const Text('Back to home'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _startNewGame(_currentSize);
            },
            child: const Text('Next'),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String _formatUtcDay(DateTime dateUtc) {
    final y = dateUtc.year.toString().padLeft(4, '0');
    final m = dateUtc.month.toString().padLeft(2, '0');
    final d = dateUtc.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Widget _buildStars(int stars) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List<Widget>.generate(3, (index) {
        final filled = index < stars;
        return Icon(
          filled ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 18,
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Play'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: PopupMenuButton<int>(
              key: const Key('difficulty-selector'),
              onSelected: (int value) => _startNewGame(value),
              tooltip: 'Change difficulty',
              padding: EdgeInsets.zero,
              position: PopupMenuPosition.under,
              itemBuilder: (context) => <PopupMenuEntry<int>>[
                PopupMenuItem<int>(
                  value: 3,
                  child: Row(
                    children: [
                      Icon(
                        Icons.grid_3x3,
                        size: 20,
                        color: _currentSize == 3
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                      const SizedBox(width: 8),
                      const Text('Easy 3×3'),
                    ],
                  ),
                ),
                PopupMenuItem<int>(
                  value: 4,
                  child: Row(
                    children: [
                      Icon(
                        Icons.grid_4x4,
                        size: 20,
                        color: _currentSize == 4
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                      const SizedBox(width: 8),
                      const Text('Medium 4×4'),
                    ],
                  ),
                ),
                PopupMenuItem<int>(
                  value: 5,
                  child: Row(
                    children: [
                      Icon(
                        Icons.grid_on,
                        size: 20,
                        color: _currentSize == 5
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                      const SizedBox(width: 8),
                      const Text('Hard 5×5'),
                    ],
                  ),
                ),
              ],
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 8.0,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.grid_on, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      '$_currentSize×$_currentSize',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(Icons.arrow_drop_down, size: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: !_isRepoLoaded || _currentFlag == null
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  if (widget.isDailyFlag)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Daily Flag',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          'Timer: ${_formatTime(_seconds)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Moves: $_moves',
                          key: const Key('moves-counter'),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final maxWidth = constraints.maxWidth * 0.9;
                          final maxHeight = constraints.maxHeight * 0.8;
                          final boardSize = maxWidth < maxHeight
                              ? maxWidth
                              : maxHeight;
                          final tileSize = boardSize / _currentSize;

                          return Container(
                            key: ValueKey(
                              'board-${_currentFlag?.id}-$_currentSize-$_restartCounter',
                            ),
                            width: boardSize,
                            height: boardSize,
                            decoration: BoxDecoration(
                              color: const Color(0xFF121212),
                              border: Border.all(
                                color: Colors.black87,
                                width: 3,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  offset: Offset(2, 4),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: Stack(
                              children: _engine.tiles.asMap().entries.map((
                                entry,
                              ) {
                                final index = entry.key;
                                final tileId = entry.value;

                                final row = index ~/ _currentSize;
                                final col = index % _currentSize;

                                double visualLeft = col * tileSize;
                                double visualTop = row * tileSize;
                                final isDragged = index == _draggedTileIndex;

                                if (isDragged) {
                                  final eIndex = _engine.emptyIndex;
                                  final eRow = eIndex ~/ _currentSize;
                                  final eCol = eIndex % _currentSize;

                                  if (eRow == row) {
                                    final maxOffset = (eCol - col) * tileSize;
                                    if (maxOffset > 0) {
                                      visualLeft += _dragOffset.clamp(
                                        0.0,
                                        maxOffset,
                                      );
                                    } else {
                                      visualLeft += _dragOffset.clamp(
                                        maxOffset,
                                        0.0,
                                      );
                                    }
                                  } else if (eCol == col) {
                                    final maxOffset = (eRow - row) * tileSize;
                                    if (maxOffset > 0) {
                                      visualTop += _dragOffset.clamp(
                                        0.0,
                                        maxOffset,
                                      );
                                    } else {
                                      visualTop += _dragOffset.clamp(
                                        maxOffset,
                                        0.0,
                                      );
                                    }
                                  }
                                }

                                if (tileId == _currentSize * _currentSize) {
                                  return AnimatedPositioned(
                                    key: ValueKey(tileId),
                                    duration: const Duration(milliseconds: 250),
                                    left: visualLeft,
                                    top: visualTop,
                                    width: tileSize,
                                    height: tileSize,
                                    child: Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF080808),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }

                                final correctRow = (tileId - 1) ~/ _currentSize;
                                final correctCol = (tileId - 1) % _currentSize;

                                return AnimatedPositioned(
                                  key: ValueKey(tileId),
                                  duration: isDragged
                                      ? Duration.zero
                                      : const Duration(milliseconds: 250),
                                  curve: Curves.easeOut,
                                  left: visualLeft,
                                  top: visualTop,
                                  width: tileSize,
                                  height: tileSize,
                                  child: GestureDetector(
                                    key: Key('puzzle-tile-position-$index'),
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () => _onTileTapped(index),
                                    onPanStart: (details) =>
                                        _onPanStart(details, index),
                                    onPanUpdate: (details) =>
                                        _onPanUpdate(details, index),
                                    onPanEnd: (details) =>
                                        _onPanEnd(details, index, tileSize),
                                    child: Container(
                                      margin: const EdgeInsets.all(2.0),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.black.withValues(
                                            alpha: 0.2,
                                          ),
                                          width: 1,
                                        ),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black26,
                                            offset: Offset(0, 2),
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(7),
                                        child: OverflowBox(
                                          maxWidth: boardSize,
                                          maxHeight: boardSize,
                                          alignment: Alignment.topLeft,
                                          child: Transform.translate(
                                            offset: Offset(
                                              -correctCol * tileSize - 3,
                                              -correctRow * tileSize - 3,
                                            ),
                                            child: Image.asset(
                                              _currentFlag!.assetPath,
                                              fit: BoxFit.cover,
                                              width: boardSize,
                                              height: boardSize,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _undoStack.isEmpty || !_isPlaying
                              ? null
                              : _undoLastMove,
                          icon: const Icon(Icons.undo),
                          label: const Text('Undo'),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _startNewGame(_currentSize),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Restart'),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Preview'),
                                content: Image.asset(_currentFlag!.assetPath),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Close'),
                                  ),
                                ],
                              ),
                            );
                          },
                          icon: const Icon(Icons.visibility),
                          label: const Text('Preview'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _GameSnapshot {
  final int gridSize;
  final List<int> tiles;
  final int moves;
  final int seconds;

  const _GameSnapshot({
    required this.gridSize,
    required this.tiles,
    required this.moves,
    required this.seconds,
  });
}
