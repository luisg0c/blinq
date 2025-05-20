import 'package:flutter/material.dart';

/// Card que mostra o saldo atual com opção de ocultar/mostrar.
class BalanceCard extends StatefulWidget {
  /// Saldo disponível.
  final double balance;

  const BalanceCard({Key? key, required this.balance}) : super(key: key);

  @override
  _BalanceCardState createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> {
  bool _obscured = false;

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF6EE1C6);
    const secondaryColor = Color(0xFF0D1517);

    // Formata valor com duas casas decimais e vírgula
    final formatted = widget.balance
        .toStringAsFixed(2)
        .replaceAll('.', ',');

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Texto do saldo
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Saldo disponível',
                    style: Theme.of(context)
                        .textTheme
                        .subtitle1
                        ?.copyWith(color: secondaryColor),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _obscured ? 'R\$ •••••' : 'R\$ $formatted',
                    style: Theme.of(context)
                        .textTheme
                        .headline5
                        ?.copyWith(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),

            // Botão de ocultar/mostrar
            IconButton(
              icon: Icon(
                _obscured ? Icons.visibility_off : Icons.visibility,
                color: secondaryColor,
              ),
              onPressed: () => setState(() => _obscured = !_obscured),
            ),
          ],
        ),
      ),
    );
  }
}
