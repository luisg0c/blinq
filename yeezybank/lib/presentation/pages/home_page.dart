import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/services/auth_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('YeezyBank'),
        backgroundColor: const Color(0xFF388E3C),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.signOut();
              Get.offAllNamed('/');
            },
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF0F2F5),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Saldo Atual:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            StreamBuilder<DocumentSnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('accounts') // ✔️ Correção do nome
                      .doc(authService.getCurrentUserId())
                      .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                final data = snapshot.data!.data() as Map<String, dynamic>;
                double realTimeBalance = (data['balance'] as num).toDouble();

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.green[600],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'R\$ ${realTimeBalance.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 28, color: Colors.white),
                  ),
                );
              },
            ),
            const SizedBox(height: 30),
            const Text(
              'Ações',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                actionButton(Icons.add, 'Depositar', '/deposit'),
                actionButton(Icons.send, 'Transferir', '/transfer'),
                actionButton(Icons.history, 'Histórico', '/transactions'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget actionButton(IconData icon, String label, String route) {
    return ElevatedButton.icon(
      onPressed: () => Get.toNamed(route),
      icon: Icon(icon, size: 24),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: const TextStyle(fontSize: 16),
        backgroundColor: Colors.green[400],
      ),
    );
  }
}
