import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'settings/puzzle_preferences.dart';

class PuzzleSettingsScreen extends StatefulWidget {
  final SharedPreferences? testPrefs;
  const PuzzleSettingsScreen({super.key, this.testPrefs});

  @override
  State<PuzzleSettingsScreen> createState() => _PuzzleSettingsScreenState();
}

class _PuzzleSettingsScreenState extends State<PuzzleSettingsScreen> {
  bool _isLoading = true;
  bool _soundEnabled = true;
  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _prefs = widget.testPrefs ?? await SharedPreferences.getInstance();
    final soundEnabled =
        _prefs!.getBool(PuzzlePreferences.soundEnabledKey) ?? true;
    if (!mounted) return;
    setState(() {
      _soundEnabled = soundEnabled;
      _isLoading = false;
    });
  }

  Future<void> _setSoundEnabled(bool value) async {
    setState(() {
      _soundEnabled = value;
    });
    await _prefs?.setBool(PuzzlePreferences.soundEnabledKey, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                SwitchListTile(
                  key: const Key('sound-toggle'),
                  title: const Text('Sound'),
                  subtitle: const Text('Enable game sound effects'),
                  value: _soundEnabled,
                  onChanged: _setSoundEnabled,
                ),
                SwitchListTile(
                  title: const Text('Vibration'),
                  subtitle: const Text('Placeholder'),
                  value: true,
                  onChanged: (bool value) {},
                ),
                ListTile(
                  title: const Text('Difficulty'),
                  subtitle: const Text('Placeholder'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {},
                ),
                ListTile(
                  title: const Text('Reset progress'),
                  subtitle: const Text('Placeholder'),
                  trailing: const Icon(Icons.delete),
                  onTap: () {},
                ),
              ],
            ),
    );
  }
}
