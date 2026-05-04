# FlagPost: Puzzle MVP Scope

## Overview
- **Product Name:** FlagPost: Puzzle
- **Package Name:** app.findpaesano
- **Concept:** A casual sliding puzzle game inspired by the classic 15-puzzle. The player rebuilds a national flag by sliding tiles and then discovers the country.

## MVP Scope
The initial version (MVP) focuses on a clean foundation with minimal features:
- Core 15-puzzle mechanics (sliding tiles) for a single hardcoded flag or a small set of flags.
- Basic HomeScreen with navigation to Game, Collection, and Settings.
- A GameScreen that supports puzzle interaction, a timer, and move counter.
- A simple CollectionScreen to show solved flags.
- A SettingsScreen with placeholders for sound, vibration, and difficulty.

## Explicitly Excluded Features (for MVP)
- Online features and backend integrations (Firebase, Cloud Firestore).
- Ads, In-App Purchases (IAP).
- Leaderboards or Google Play Games integration.
- Game engines like Flame (sticking to standard Flutter widgets for now).
- Complex local persistence like Hive/Isar (use basic SharedPreferences if absolutely necessary, but minimal state is preferred).
- Social and travel features from the legacy FlagPost app. (Note: The legacy social code has been isolated and is not part of the new app path).

## Planned Later Features
- Dynamic flag generation and level progression.
- Persistent local storage for the collection of solved flags.
- Sound effects and haptic feedback.
- Multiple difficulty levels (e.g., 3x3, 4x4, 5x5 grids).
- "Discover the country" trivia and information revealed after solving a flag.