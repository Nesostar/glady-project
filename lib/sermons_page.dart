import 'package:flutter/material.dart';

class SermonsPage extends StatelessWidget {
  const SermonsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sermons')),
      body: const Center(
        child: Text('Sermons Page', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
