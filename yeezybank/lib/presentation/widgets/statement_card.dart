import 'package:flutter/material.dart';

class StatementCard extends StatelessWidget {
  const StatementCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      height: 115,
      decoration: BoxDecoration(
        color: const Color(0xFF444444),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF6CE1A3),
          width: 1,
          opacity: 0.24,
        ),
      ),
      child: const Center(
        child: Icon(Icons.lock_outline, color: Colors.white, size: 24),
      ),
    );
  }
}
