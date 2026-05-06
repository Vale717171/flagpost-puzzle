# FlagPost: Puzzle

FlagPost: Puzzle is an offline casual sliding puzzle game where players rebuild country flags and discover quick country facts after each solve.

## Current Features

- Sliding puzzle gameplay with selectable grid size (3x3, 4x4, 5x5)
- Local timer and move counter per run
- Per-flag best time and best moves stored locally
- Flag reveal with country name, capital, and short fact on completion
- Home, Collection, and Settings screens
- Light and dark theme support

## Tech Stack

- Flutter (Dart)
- Material 3 UI
- `shared_preferences` for local persistence
- Local asset-based flag dataset (`assets/flags/`)

## Offline-First

The app runs fully offline. Puzzle content is loaded from bundled local assets, and progress records are stored on-device.

## Run Locally

```bash
flutter pub get
flutter run
```

## Test

```bash
flutter analyze
flutter test
```

## Current Roadmap

- richer home screen
- daily flag
- star rating
- collection
- sound effects
- optional AdMob banner later
