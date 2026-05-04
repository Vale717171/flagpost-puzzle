import 'package:flutter/material.dart';

class PuzzleSettingsScreen extends StatelessWidget {
  const PuzzleSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          SwitchListTile(
            title: const Text('Sound'),
            subtitle: const Text('Placeholder'),
            value: true,
            onChanged: (bool value) {},
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
