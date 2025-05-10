import 'package:flutter/material.dart';

void main() {
  runApp(const BlinqApp());
}

class BlinqApp extends StatelessWidget {
  const BlinqApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blinq',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blinq'),
      ),
      body: const Center(
        child: Text('Bem-vindo ao Blinq!'),
      ),
    );
  }
}
