import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
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
    Widget card = Card(
      width: double.infinity,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Saldo Disponível',
            style: TextStyle(
              style: AppTextStyles.body,
              color: AppColors.textColor,
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
                return const Center(
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
                children: [ Text(
                      'R\$ ${realTimeBalance.toStringAsFixed(2)}',              
                      style: AppTextStyles.title.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                  Icon(
                    LineIcons.wallet,
                    color: AppColors.primaryColor,
                    size: 32,
                  )
                      ),
                    ),                  
                ],
              );
            },
          ),
        ],
      ),
    );
    
    if (animation != null) {
      return ScaleTransition(
        scale: animation!,
        child: card,
      );
    }

    return card;
  }
}