import 'package:flutter/material.dart';
import 'game_screen.dart';
import 'collection_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          const Positioned.fill(
            child: _BackgroundGrid(),
          ),
          // Foreground
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),
                  // Title
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface.withAlpha(217),
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
                      ],
                    ),
                  ),
                  const Spacer(flex: 1),
                  // Play Button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const GameScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 20),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                    child: const Text('PLAY', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 32),
                  // Secondary Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => const CollectionScreen()),
                          );
                        },
                        icon: const Icon(Icons.collections),
                        label: const Text('Collection'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          backgroundColor: Theme.of(context).colorScheme.surface.withAlpha(230),
                        ),
                      ),
                      const SizedBox(width: 16),
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => const PuzzleSettingsScreen()),
                          );
                        },
                        icon: const Icon(Icons.settings),
                        label: const Text('Settings'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          backgroundColor: Theme.of(context).colorScheme.surface.withAlpha(230),
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
          }
        ),
      ),
    );
  }
}
