import 'package:flutter/material.dart';
import 'package:get/get.dart';

class QuickActionsWidget extends StatelessWidget {
  const QuickActionsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _actionButton(Icons.add, 'Depositar', '/deposit'),
        _actionButton(Icons.send, 'Transferir', '/transfer'),
      ],
    );
  }
  
  Widget _actionButton(IconData icon, String label, String route) {
    return ElevatedButton.icon(
      onPressed: () => Get.toNamed(route),
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: const TextStyle(fontSize: 16),
        backgroundColor: Colors.green[400],
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}