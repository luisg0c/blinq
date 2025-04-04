import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class BalanceCard extends StatelessWidget {
  final String userId;
  final Animation<double>? animation;

  const BalanceCard({
    Key? key,
    required this.userId,
    this.animation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget card = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[800]!, Colors.green[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Saldo Disponível',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('accounts')
                .doc(userId)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox(
                  height: 40,
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                );
              }

              final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
              double realTimeBalance = (data['balance'] as num?)?.toDouble() ?? 0.0;

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'R\$ ${realTimeBalance.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 28, 
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Icon(
                    Icons.account_balance_wallet,
                    color: Colors.white70,
                    size: 28,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
    
    // Se existir animação, envolve o card com ScaleTransition
    if (animation != null) {
      return ScaleTransition(
        scale: animation!,
        child: card,
      );
    }
    
    return card;
  }
}