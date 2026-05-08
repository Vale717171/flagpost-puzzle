import 'package:flagpost/puzzle/data/flag_country.dart';
import 'package:flagpost/puzzle/data/flag_repository.dart';
import 'package:flagpost/puzzle/settings/puzzle_preferences.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CollectionScreen extends StatefulWidget {
  final FlagRepository? testFlagRepo;
  final SharedPreferences? testPrefs;
  const CollectionScreen({super.key, this.testFlagRepo, this.testPrefs});

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  late final FlagRepository _flagRepo;
  SharedPreferences? _prefs;
  bool _isLoading = true;
  List<_FlagCollectionEntry> _entries = [];
  _CollectionFilter _selectedFilter = _CollectionFilter.all;

  @override
  void initState() {
    super.initState();
    _flagRepo = widget.testFlagRepo ?? FlagRepository();
    _load();
  }

  Future<void> _load() async {
    try {
      if (widget.testFlagRepo == null) {
        await _flagRepo.loadAll();
      }
      _prefs = widget.testPrefs ?? await SharedPreferences.getInstance();
      _entries = _flagRepo.flags
          .map((flag) => _buildEntry(flag, _prefs!))
          .toList(growable: false);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  _FlagCollectionEntry _buildEntry(FlagCountry flag, SharedPreferences prefs) {
    const sizes = [3, 4, 5];

    int? bestTime;
    int? bestMoves;
    int bestStars = 0;
    bool solved = false;

    for (final size in sizes) {
      final time = prefs.getInt(PuzzlePreferences.bestTimeKey(flag.id, size));
      final moves = prefs.getInt(PuzzlePreferences.bestMovesKey(flag.id, size));
      final stars = prefs.getInt(PuzzlePreferences.bestStarsKey(flag.id, size));

      if (time != null || moves != null || stars != null) {
        solved = true;
      }
      if (time != null && (bestTime == null || time < bestTime)) {
        bestTime = time;
      }
      if (moves != null && (bestMoves == null || moves < bestMoves)) {
        bestMoves = moves;
      }
      if (stars != null && stars > bestStars) {
        bestStars = stars;
      }
    }

    return _FlagCollectionEntry(
      flag: flag,
      solved: solved,
      bestTime: bestTime,
      bestMoves: bestMoves,
      bestStars: bestStars,
    );
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _showSolvedDetails(_FlagCollectionEntry entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(entry.flag.countryName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Capital: ${entry.flag.capital}'),
            const SizedBox(height: 8),
            Text(entry.flag.shortFact),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Best Stars: '),
                _starsWidget(entry.bestStars),
              ],
            ),
            Text(
              'Best Time: ${entry.bestTime == null ? '-' : _formatTime(entry.bestTime!)}',
            ),
            Text('Best Moves: ${entry.bestMoves?.toString() ?? '-'}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _starsWidget(int stars) {
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

  List<_FlagCollectionEntry> _visibleEntries() {
    switch (_selectedFilter) {
      case _CollectionFilter.all:
        return _entries;
      case _CollectionFilter.solved:
        return _entries.where((e) => e.solved).toList(growable: false);
      case _CollectionFilter.unsolved:
        return _entries.where((e) => !e.solved).toList(growable: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final visibleEntries = _visibleEntries();

    return Scaffold(
      appBar: AppBar(title: const Text('Collection')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                  child: Row(
                    children: [
                      ChoiceChip(
                        key: const Key('filter-all'),
                        label: const Text('All'),
                        selected: _selectedFilter == _CollectionFilter.all,
                        onSelected: (_) => setState(
                          () => _selectedFilter = _CollectionFilter.all,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        key: const Key('filter-solved'),
                        label: const Text('Solved'),
                        selected: _selectedFilter == _CollectionFilter.solved,
                        onSelected: (_) => setState(
                          () => _selectedFilter = _CollectionFilter.solved,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        key: const Key('filter-unsolved'),
                        label: const Text('Unsolved'),
                        selected: _selectedFilter == _CollectionFilter.unsolved,
                        onSelected: (_) => setState(
                          () => _selectedFilter = _CollectionFilter.unsolved,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: visibleEntries.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.9,
                        ),
                    itemBuilder: (context, index) {
                      final entry = visibleEntries[index];
                      return InkWell(
                        key: Key('collection-item-${entry.flag.id}'),
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          if (entry.solved) {
                            _showSolvedDetails(entry);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Solve this flag to unlock details.',
                                ),
                              ),
                            );
                          }
                        },
                        child: Ink(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).colorScheme.outlineVariant,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: ColorFiltered(
                                            colorFilter: entry.solved
                                                ? const ColorFilter.mode(
                                                    Colors.transparent,
                                                    BlendMode.multiply,
                                                  )
                                                : const ColorFilter.mode(
                                                    Colors.grey,
                                                    BlendMode.saturation,
                                                  ),
                                            child: Image.asset(
                                              entry.flag.assetPath,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (!entry.solved)
                                        const Positioned(
                                          right: 6,
                                          top: 6,
                                          child: Icon(
                                            Icons.lock,
                                            color: Colors.white,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  entry.flag.countryName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                entry.solved
                                    ? _starsWidget(entry.bestStars)
                                    : Text(
                                        'Unsolved',
                                        style: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

enum _CollectionFilter { all, solved, unsolved }

class _FlagCollectionEntry {
  final FlagCountry flag;
  final bool solved;
  final int? bestTime;
  final int? bestMoves;
  final int bestStars;

  const _FlagCollectionEntry({
    required this.flag,
    required this.solved,
    required this.bestTime,
    required this.bestMoves,
    required this.bestStars,
  });
}
