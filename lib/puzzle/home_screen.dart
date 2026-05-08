import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/flag_repository.dart';
import 'game_screen.dart';
import 'collection_screen.dart';
import 'settings/puzzle_preferences.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final FlagRepository? testFlagRepo;
  final SharedPreferences? testPrefs;
  const HomeScreen({super.key, this.testFlagRepo, this.testPrefs});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<_HomeProgressSummaryData> _summaryFuture;

  @override
  void initState() {
    super.initState();
    _refreshSummary();
  }

  void _refreshSummary() {
    _summaryFuture = _loadSummary();
  }

  Future<void> _pushAndRefresh(Widget screen) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => screen),
    );
    if (!mounted) return;
    setState(_refreshSummary);
  }

  Future<_HomeProgressSummaryData> _loadSummary() async {
    final repo = widget.testFlagRepo ?? FlagRepository();
    if (widget.testFlagRepo == null) {
      await repo.loadAll();
    }
    final prefs = widget.testPrefs ?? await SharedPreferences.getInstance();

    int solvedFlags = 0;
    for (final flag in repo.flags) {
      bool solved = false;
      for (final size in const [3, 4, 5]) {
        if (prefs.getInt(PuzzlePreferences.bestTimeKey(flag.id, size)) !=
                null ||
            prefs.getInt(PuzzlePreferences.bestMovesKey(flag.id, size)) !=
                null ||
            prefs.getInt(PuzzlePreferences.bestStarsKey(flag.id, size)) !=
                null) {
          solved = true;
          break;
        }
      }
      if (solved) solvedFlags++;
    }

    final totalFlags = repo.flags.length;
    final streak = prefs.getInt(PuzzlePreferences.dailyStreakCountKey) ?? 0;

    return _HomeProgressSummaryData(
      solvedFlags: solvedFlags,
      totalFlags: totalFlags,
      dailyStreak: streak,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          const Positioned.fill(child: _BackgroundGrid()),
          // Foreground
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),
                  // Title
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 24,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surface.withAlpha(217),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(26),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'FlagPost',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1.5,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        Text(
                          'PUZZLE',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 10,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Slide tiles, rebuild flags, beat your best.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(flex: 1),
                  FutureBuilder<_HomeProgressSummaryData>(
                    future: _summaryFuture,
                    builder: (context, snapshot) {
                      final data = snapshot.data;
                      if (data == null) {
                        return const SizedBox.shrink();
                      }
                      return Container(
                        key: const Key('home-progress-summary'),
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surface.withAlpha(220),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outlineVariant,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Solved: ${data.solvedFlags}/${data.totalFlags}',
                              key: const Key('home-solved-summary'),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (data.dailyStreak > 0)
                              Text(
                                'Daily streak: ${data.dailyStreak}',
                                key: const Key('home-daily-streak'),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                  SizedBox(
                    width: 280,
                    child: ElevatedButton(
                      onPressed: () {
                        _pushAndRefresh(
                          GameScreen(testFlagRepo: widget.testFlagRepo),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 48,
                          vertical: 18,
                        ),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onPrimary,
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                      ),
                      child: const Text(
                        'Play Random',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: 280,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _pushAndRefresh(
                          GameScreen(
                            isDailyFlag: true,
                            testFlagRepo: widget.testFlagRepo,
                          ),
                        );
                      },
                      icon: const Icon(Icons.today),
                      label: const Text(
                        'Daily Flag',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 36,
                          vertical: 14,
                        ),
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2,
                        ),
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.surface.withAlpha(230),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Secondary Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          _pushAndRefresh(
                            CollectionScreen(
                              testFlagRepo: widget.testFlagRepo,
                              testPrefs: widget.testPrefs,
                            ),
                          );
                        },
                        icon: const Icon(Icons.collections),
                        label: const Text('Collection'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.surface.withAlpha(230),
                        ),
                      ),
                      const SizedBox(width: 16),
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  const PuzzleSettingsScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.settings),
                        label: const Text('Settings'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.surface.withAlpha(230),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(flex: 2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeProgressSummaryData {
  final int solvedFlags;
  final int totalFlags;
  final int dailyStreak;

  const _HomeProgressSummaryData({
    required this.solvedFlags,
    required this.totalFlags,
    required this.dailyStreak,
  });
}

class _BackgroundGrid extends StatelessWidget {
  const _BackgroundGrid();

  static const _bgFlags = [
    'assets/flags/images/it.png',
    'assets/flags/images/fr.png',
    'assets/flags/images/jp.png',
    'assets/flags/images/br.png',
    'assets/flags/images/za.png',
    'assets/flags/images/au.png',
    'assets/flags/images/ca.png',
    'assets/flags/images/gb.png',
    'assets/flags/images/kr.png',
    'assets/flags/images/ar.png',
    'assets/flags/images/es.png',
    'assets/flags/images/mx.png',
    'assets/flags/images/in.png',
    'assets/flags/images/ru.png',
    'assets/flags/images/de.png',
    'assets/flags/images/ch.png',
  ];

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Opacity(
        opacity: 0.2, // increased opacity slightly for better visual
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Fill based on screen size, maybe 4 columns or 3 based on width
            final crossAxisCount = constraints.maxWidth > 600 ? 5 : 3;
            // Provide enough items to fill typical screen heights
            final itemCount = crossAxisCount * 10;

            return GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: 1.2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 24,
              ),
              itemCount: itemCount,
              itemBuilder: (context, index) {
                final asset = _bgFlags[index % _bgFlags.length];

                final isEven = index % 2 == 0;
                final angle = isEven ? 0.1 : -0.1;
                final yOffset = (index % crossAxisCount) * 16.0;

                return Transform.translate(
                  offset: Offset(0, yOffset),
                  child: Transform.rotate(
                    angle: angle,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(51),
                            blurRadius: 4,
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(asset, fit: BoxFit.cover),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
