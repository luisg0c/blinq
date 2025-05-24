import 'package:flutter/material.dart';

class BalanceCard extends StatefulWidget {
  final double balance;
  final VoidCallback? onDeposit;
  final VoidCallback? onTransfer;
  final VoidCallback? onPix;

  const BalanceCard({
    Key? key, 
    required this.balance,
    this.onDeposit,
    this.onTransfer,
    this.onPix,
  }) : super(key: key);

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> {
  bool _isBalanceVisible = true;

  void _toggleVisibility() {
    setState(() {
      _isBalanceVisible = !_isBalanceVisible;
    });
  }

  String _formatCurrency(double value) {
    return value.toStringAsFixed(2).replaceAll('.', ',');
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF6EE1C6);
    const secondaryColor = Color(0xFF0D1517);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6EE1C6),
            Color(0xFF5BC4A8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header simples
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Saldo Blinq',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              GestureDetector(
                onTap: _toggleVisibility,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    _isBalanceVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Saldo principal
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              _isBalanceVisible 
                  ? 'R\$ ${_formatCurrency(widget.balance)}'
                  : 'R\$ ••••••',
              key: ValueKey(_isBalanceVisible),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Ações P2P principais
          Row(
            children: [
              Expanded(
                child: _buildP2PAction(
                  icon: Icons.add_circle_outline,
                  label: 'Depositar',
                  onTap: widget.onDeposit,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildP2PAction(
                  icon: Icons.send,
                  label: 'Enviar',
                  onTap: widget.onTransfer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildP2PAction(
                  icon: Icons.qr_code_scanner,
                  label: 'PIX',
                  onTap: widget.onPix,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildP2PAction({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}