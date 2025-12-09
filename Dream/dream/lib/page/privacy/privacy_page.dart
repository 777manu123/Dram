import 'package:flutter/material.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: const Text(
          'Privacy policy placeholder. Add your privacy text here.\n\nThis page should include details on data handling, storage and user rights.',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
