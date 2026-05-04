import 'dart:async';

import 'package:flagpost/puzzle/logic/puzzle_engine.dart';
import 'package:flutter/material.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late PuzzleEngine _engine;
  int _moves = 0;
  Timer? _timer;
  int _seconds = 0;
  int _currentSize = 4;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _startNewGame(_currentSize);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startNewGame(int size) {
    setState(() {
      _currentSize = size;
      _engine = PuzzleEngine(size);
      // Determine move count based on size for a good shuffle
      final shuffleMoves = size == 3 ? 50 : size == 4 ? 100 : 150;
      _engine.shuffle(shuffleMoves);
      _moves = 0;
      _seconds = 0;
      _isPlaying = true;
    });
    _timer?.cancel();
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

    if (_engine.canMove(index)) {
      setState(() {
        _engine.move(index);
        _moves++;

        if (_engine.isSolved) {
          _isPlaying = false;
          _timer?.cancel();
          _showCompletionDialog();
        }
      });
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Flag completed'),
        content: Text('Time: ${_formatTime(_seconds)}\nMoves: $_moves'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Play'),
        actions: [
          PopupMenuButton<int>(
            onSelected: _startNewGame,
            icon: const Icon(Icons.grid_on),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 3, child: Text('Easy 3x3')),
              const PopupMenuItem(value: 4, child: Text('Medium 4x4')),
              const PopupMenuItem(value: 5, child: Text('Hard 5x5')),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text('Timer: ${_formatTime(_seconds)}',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  Text('Moves: $_moves',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final maxWidth = constraints.maxWidth * 0.9;
                    final maxHeight = constraints.maxHeight * 0.8;
                    final boardSize =
                        maxWidth < maxHeight ? maxWidth : maxHeight;
                    final tileSize = boardSize / _currentSize;

                    return Container(
                      width: boardSize,
                      height: boardSize,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        border: Border.all(color: Colors.black26, width: 2),
                      ),
                      child: Stack(
                        children: _engine.tiles.asMap().entries.map((entry) {
                          final index = entry.key;
                          final tileId = entry.value;

                          if (tileId == _currentSize * _currentSize) {
                            return const SizedBox.shrink(); // Empty tile
                          }

                          final row = index ~/ _currentSize;
                          final col = index % _currentSize;
                          final correctRow = (tileId - 1) ~/ _currentSize;
                          final correctCol = (tileId - 1) % _currentSize;

                          return AnimatedPositioned(
                            key: ValueKey(tileId),
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOut,
                            left: col * tileSize,
                            top: row * tileSize,
                            width: tileSize,
                            height: tileSize,
                            child: GestureDetector(
                              onTap: () => _onTileTapped(index),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.white, width: 1),
                                ),
                                child: ClipRect(
                                  child: OverflowBox(
                                    maxWidth: boardSize,
                                    maxHeight: boardSize,
                                    alignment: Alignment(
                                      -1.0 +
                                          (correctCol / (_currentSize - 1)) *
                                              2.0,
                                      -1.0 +
                                          (correctRow / (_currentSize - 1)) *
                                              2.0,
                                    ),
                                    child: Image.asset(
                                      'assets/icon.png',
                                      fit: BoxFit.cover,
                                      width: boardSize,
                                      height: boardSize,
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
                          content: Image.asset('assets/icon.png'),
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
