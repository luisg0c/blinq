import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';
import '../services/transaction_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double balance = 0.0;
  final authService = AuthService();
  final transactionService = TransactionService();

  @override
  void initState() {
    super.initState();
    fetchBalance();
  }

  Future<void> fetchBalance() async {
    try {
      final userId = authService.getCurrentUserId();
      double currentBalance = await transactionService.getUserBalance(userId);
      setState(() {
        balance = currentBalance;
      });
    } catch (e) {
      Get.snackbar('Erro', 'Não foi possível obter o saldo');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Urubu do Pix'),
        backgroundColor: const Color(0xFF388E3C),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.signOut();
              Get.offAllNamed('/');
            },
          )
        ],
      ),
      backgroundColor: const Color(0xFFF0F2F5),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Saldo Atual', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.green[600],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'R\$ ${balance.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 28, color: Colors.white),
              ),
            ),
            const SizedBox(height: 30),
            const Text('Ações', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
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
      onPressed: () async {
        final result = await Get.toNamed(route);
        if (result == true) fetchBalance(); // Atualiza saldo após transação
      },
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
