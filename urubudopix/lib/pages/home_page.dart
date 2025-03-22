import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    final double balance = 84000.0;
    final String accountNumber = '11111111';
    final String userName = 'Bem-vindo de volta, Urubu!';
    final List<Map<String, dynamic>> transactions = [
      {'name': 'João da Silva', 'id': '12345678', 'date': '21-03-2025', 'amount': 2500.0},
      {'name': 'Maria Oliveira', 'id': '87654321', 'date': '20-03-2025', 'amount': 1800.0},
      {'name': 'Pix do Samuca', 'id': '14785236', 'date': '19-03-2025', 'amount': 4000.0},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black87),
            onPressed: () async {
              await authService.signOut();
              Get.offAllNamed('/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(userName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 20),

            const Text('Visão Geral', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF388E3C),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Saldo Total', style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: 4),
                      Text('R\$ $balance', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Text('Conta: $accountNumber', style: const TextStyle(color: Colors.white)),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Text('Meus Cartões', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset('assets/images/logo_text.png', height: 40),
                  const SizedBox(height: 20),
                  const Text('1234  5678  9012  3456', style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  const Text('Urubu do Pix', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Text('Transações Recentes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 12),

            ...transactions.map((tx) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Color(0xFF388E3C),
                          child: Icon(Icons.sync_alt, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(tx['name'], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                            Text('${tx['id']}  ${tx['date']}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                          ],
                        ),
                      ],
                    ),
                    Text('R\$ ${tx['amount']}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF388E3C))),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
