import 'dart:math';

class PuzzleEngine {
  final int size;
  final List<int> tiles;

  PuzzleEngine(this.size)
      : tiles = List.generate(size * size, (index) => index + 1) {
    if (size != 3 && size != 4 && size != 5) {
      throw ArgumentError('Only 3x3, 4x4, and 5x5 grids are supported');
    }
  }

  PuzzleEngine.withTiles(this.size, List<int> initialTiles)
      : tiles = List.from(initialTiles) {
    if (size != 3 && size != 4 && size != 5) {
      throw ArgumentError('Only 3x3, 4x4, and 5x5 grids are supported');
    }
    if (tiles.length != size * size) {
      throw ArgumentError('Tiles length must be size * size');
    }
  }

  int get emptyIndex {
    final emptyId = size * size;
    return tiles.indexOf(emptyId);
  }

  bool canMove(int index) {
    if (index < 0 || index >= tiles.length) return false;

    final eIndex = emptyIndex;
    if (index == eIndex) return false;

    final row = index ~/ size;
    final col = index % size;
    final eRow = eIndex ~/ size;
    final eCol = eIndex % size;

    return (row == eRow && (col - eCol).abs() == 1) ||
        (col == eCol && (row - eRow).abs() == 1);
  }

  void move(int index) {
    if (canMove(index)) {
      final eIndex = emptyIndex;
      final temp = tiles[index];
      tiles[index] = tiles[eIndex];
      tiles[eIndex] = temp;
    }
  }

  bool get isSolved {
    for (int i = 0; i < tiles.length; i++) {
      if (tiles[i] != i + 1) return false;
    }
    return true;
  }

  void shuffle(int moveCount, [Random? random]) {
    final rand = random ?? Random();

    // Reset to solved state before shuffling to ensure solvability
    for (int i = 0; i < tiles.length; i++) {
      tiles[i] = i + 1;
    }

    int? previousEmptyIndex;

    for (int i = 0; i < moveCount; i++) {
      final validMoves = <int>[];
      final eIndex = emptyIndex;
      final row = eIndex ~/ size;
      final col = eIndex % size;

      if (row > 0) validMoves.add(eIndex - size); // Up
      if (row < size - 1) validMoves.add(eIndex + size); // Down
      if (col > 0) validMoves.add(eIndex - 1); // Left
      if (col < size - 1) validMoves.add(eIndex + 1); // Right

      if (previousEmptyIndex != null) {
        validMoves.remove(previousEmptyIndex);
      }

      if (validMoves.isNotEmpty) {
        final moveIndex = validMoves[rand.nextInt(validMoves.length)];
        previousEmptyIndex = eIndex;
        move(moveIndex);
      }
    }
  }
}
