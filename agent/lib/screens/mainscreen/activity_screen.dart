import 'package:flutter/material.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Screen'),
      ),
      body: const Center(
        child: Text(
          'Welcome to the Activity Screen!',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
