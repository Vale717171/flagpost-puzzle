import 'package:flutter/material.dart';

class CollectionScreen extends StatelessWidget {
  const CollectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Collection'),
      ),
      body: const Center(
        child: Text(
          'Your solved flags will appear here',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
