import 'package:flagpost/puzzle/data/flag_country.dart';
import 'package:flagpost/puzzle/data/flag_repository.dart';
import 'package:flutter_test/flutter_test.dart';

List<FlagCountry> _flags() => [
  FlagCountry(
    id: 'a',
    countryName: 'A',
    capital: 'A',
    continent: 'A',
    assetPath: 'assets/flags/images/it.png',
    shortFact: 'A',
  ),
  FlagCountry(
    id: 'b',
    countryName: 'B',
    capital: 'B',
    continent: 'B',
    assetPath: 'assets/flags/images/fr.png',
    shortFact: 'B',
  ),
  FlagCountry(
    id: 'c',
    countryName: 'C',
    capital: 'C',
    continent: 'C',
    assetPath: 'assets/flags/images/jp.png',
    shortFact: 'C',
  ),
];

void main() {
  group('FlagRepository dailyFlag', () {
    test('returns the same flag for the same UTC date', () {
      final repo = FlagRepository(initialFlags: _flags());

      final a = repo.dailyFlag(utcNow: DateTime.utc(2026, 5, 6, 0, 1));
      final b = repo.dailyFlag(utcNow: DateTime.utc(2026, 5, 6, 23, 59));

      expect(a.id, b.id);
    });

    test('is based on UTC day boundaries', () {
      final repo = FlagRepository(initialFlags: _flags());

      final beforeMidnightUtc = repo.dailyFlag(
        utcNow: DateTime.parse('2026-05-06T23:59:59Z'),
      );
      final afterMidnightUtc = repo.dailyFlag(
        utcNow: DateTime.parse('2026-05-07T00:00:00Z'),
      );

      expect(beforeMidnightUtc.id, isNot(afterMidnightUtc.id));
    });

    test('different repository instances give the same daily flag', () {
      final repo1 = FlagRepository(initialFlags: _flags());
      final repo2 = FlagRepository(initialFlags: _flags());
      final date = DateTime.utc(2030, 1, 15, 12, 0);

      expect(
        repo1.dailyFlag(utcNow: date).id,
        repo2.dailyFlag(utcNow: date).id,
      );
    });
  });
}
