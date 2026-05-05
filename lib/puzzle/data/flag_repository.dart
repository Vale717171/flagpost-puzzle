import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';

import 'flag_country.dart';

class FlagRepository {
  List<FlagCountry> _flags = [];
  final _random = Random();

  Future<void> loadAll() async {
    final String jsonString = await rootBundle.loadString('assets/flags/flags.json');
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
}
