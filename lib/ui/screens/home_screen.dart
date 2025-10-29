import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('5D Chess'),
      ),
      body: const Center(
        child: Text('Welcome to 5D Chess!'),
      ),
    );
  }
}