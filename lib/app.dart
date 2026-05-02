import 'package:flutter/material.dart';
import 'package:product_db_flutter/core/env.dart';

class ProductDbApp extends StatelessWidget {
  const ProductDbApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Product DB',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const _BootstrapScreen(),
    );
  }
}

class _BootstrapScreen extends StatelessWidget {
  const _BootstrapScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product DB')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Bootstrap OK'),
            const SizedBox(height: 8),
            Text('API: ${Env.apiBaseUrl}'),
          ],
        ),
      ),
    );
  }
}
