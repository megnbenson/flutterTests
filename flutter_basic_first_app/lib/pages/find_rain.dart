// lib/pages/go_here_page.dart
import 'package:flutter/material.dart';

class FindRainPage extends StatelessWidget {
  const FindRainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Go Here'),
      ),
      body: Center(
        child: Text(
          'Go here',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
