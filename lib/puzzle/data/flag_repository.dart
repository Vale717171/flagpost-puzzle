import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';

import 'flag_country.dart';

class FlagRepository {
  List<FlagCountry> _flags = [];
  final _random = Random();

  FlagRepository({List<FlagCountry>? initialFlags}) {
    if (initialFlags != null) {
      _flags = List<FlagCountry>.from(initialFlags);
    }
  }

  Future<void> loadAll() async {
    final String jsonString = await rootBundle.loadString(
      'assets/flags/flags.json',
    );
    final List<dynamic> jsonList = jsonDecode(jsonString);
    _flags = jsonList.map((json) => FlagCountry.fromJson(json)).toList();
  }

  FlagCountry randomFlag() {
    if (_flags.isEmpty) {
      throw StateError('Flags not loaded. Call loadAll() first.');
    }
    final index = _random.nextInt(_flags.length);
    return _flags[index];
  }

  FlagCountry dailyFlag({DateTime? utcNow}) {
    if (_flags.isEmpty) {
      throw StateError('Flags not loaded. Call loadAll() first.');
    }
    final nowUtc = (utcNow ?? DateTime.now()).toUtc();
    final dayUtc = DateTime.utc(nowUtc.year, nowUtc.month, nowUtc.day);
    final epochUtc = DateTime.utc(1970, 1, 1);
    final dayIndex = dayUtc.difference(epochUtc).inDays;
    final flagIndex = dayIndex % _flags.length;
    return _flags[flagIndex];
  }
}
