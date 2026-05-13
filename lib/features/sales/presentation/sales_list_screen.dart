import 'package:flutter/material.dart';

class SalesListScreen extends StatelessWidget {
  const SalesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sales')),
      body: const Center(child: Text('Sales list (Phase 3)')),
    );
  }
}
