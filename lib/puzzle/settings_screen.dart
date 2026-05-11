import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'settings/puzzle_preferences.dart';

class PuzzleSettingsScreen extends StatefulWidget {
  static final Uri supportUri = Uri.parse(
    'https://www.buymeacoffee.com/Vale71',
  );

  final SharedPreferences? testPrefs;
  final Future<bool> Function(Uri uri)? launchExternalUrl;

  const PuzzleSettingsScreen({
    super.key,
    this.testPrefs,
    this.launchExternalUrl,
  });

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

  Future<bool> _launchExternalUrl(Uri uri) {
    final launcher = widget.launchExternalUrl;
    if (launcher != null) {
      return launcher(uri);
    }
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _openSupportLink() async {
    final didLaunch = await _launchExternalUrl(PuzzleSettingsScreen.supportUri);
    if (!mounted || didLaunch) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not open support page.')),
    );
  }

  Future<void> _resetProgress() async {
    final prefs = _prefs;
    if (prefs == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Progress?'),
        content: const Text(
          'This will clear best times, moves, stars, and daily streak data. '
          'Sound and other settings will stay unchanged.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final keys = prefs.getKeys();
    final keysToRemove = <String>{
      PuzzlePreferences.dailyStreakCountKey,
      PuzzlePreferences.dailyStreakLastCompletedDayKey,
    };
    for (final key in keys) {
      for (final prefix in PuzzlePreferences.progressKeyPrefixes) {
        if (key.startsWith(prefix)) {
          keysToRemove.add(key);
          break;
        }
      }
    }

    for (final key in keysToRemove) {
      await prefs.remove(key);
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Progress reset complete.')),
    );
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
                ListTile(
                  key: const Key('reset-progress-tile'),
                  title: const Text('Reset Progress'),
                  subtitle: const Text(
                    'Clear best times, moves, stars, and daily streak',
                  ),
                  trailing: const Icon(Icons.delete_outline),
                  onTap: _resetProgress,
                ),
                const SizedBox(height: 12),
                ListTile(
                  title: const Text('Support the project'),
                  subtitle: const Text(
                    'If you enjoy FlagPost: Puzzle, you can support development.',
                  ),
                ),
                ListTile(
                  key: const Key('support-project-tile'),
                  title: const Text('Buy me a coffee'),
                  trailing: const Icon(Icons.coffee_outlined),
                  onTap: _openSupportLink,
                ),
                const SizedBox(height: 12),
                ListTile(
                  title: const Text('About'),
                ),
                ListTile(
                  title: const Text('FlagPost: Puzzle'),
                  subtitle: const Text(
                    'Offline game. Progress and settings are stored locally on your device.',
                  ),
                ),
                ListTile(
                  title: const Text('Flag assets'),
                  subtitle: const Text(
                    'Country flags are bundled app assets used for gameplay.',
                  ),
                ),
              ],
            ),
    );
  }
}
