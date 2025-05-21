import 'package:flutter/material.dart';

class BalanceCard extends StatefulWidget {
  final double balance;

  const BalanceCard({Key? key, required this.balance}) : super(key: key);

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> {
  bool _obscured = false;

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF6EE1C6);
    const secondaryColor = Color(0xFF0D1517);

    final formatted = widget.balance
        .toStringAsFixed(2)
        .replaceAll('.', ',');

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Saldo disponível',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: secondaryColor,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _obscured ? 'R\$ ••••••' : 'R\$ $formatted',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(_obscured ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => _obscured = !_obscured),
            )
          ],
        ),
      ),
    );
  }
}
