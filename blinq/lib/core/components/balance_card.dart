// lib/core/components/balance_card.dart - VERSÃO CORRIGIDA

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';
import '../../routes/app_routes.dart';

class BalanceCard extends StatefulWidget {
  final double balance;
  final VoidCallback? onDeposit;
  final VoidCallback? onTransfer;
  final VoidCallback? onPix;

  const BalanceCard({
    super.key,
    required this.balance,
    this.onDeposit,
    this.onTransfer,
    this.onPix,
  });

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> {
  bool _isBalanceVisible = false; // ✅ Por padrão, saldo oculto
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            Color(0xFF5BC4A8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ Header com botão de visibilidade
          _buildHeader(),
          
          const SizedBox(height: 16),

          // ✅ Saldo principal
          _buildBalanceDisplay(),

          const SizedBox(height: 20),

          // ✅ Ações principais
          _buildActionButtons(),
        ],
      ),
    );
  }

  /// ✅ HEADER COM BOTÃO DE VISIBILIDADE
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Saldo Blinq',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _getStatusText(),
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
              ),
            ),
          ],
        ),
        
        // ✅ Botão de visibilidade
        GestureDetector(
          onTap: _toggleVisibility,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Icon(
                    _isBalanceVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.white,
                    size: 18,
                  ),
          ),
        ),
      ],
    );
  }

  /// ✅ DISPLAY DO SALDO
  Widget _buildBalanceDisplay() {
    return AnimatedSwitcher(
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
    );
  }

  /// ✅ BOTÕES DE AÇÃO
  Widget _buildActionButtons() {
    return Row(
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
    );
  }

  /// ✅ BOTÃO DE AÇÃO INDIVIDUAL
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

  /// ✅ TOGGLE DE VISIBILIDADE COM PIN
  Future<void> _toggleVisibility() async {
    if (_isBalanceVisible) {
      // Se está visível, apenas ocultar
      setState(() {
        _isBalanceVisible = false;
      });
      
      Get.snackbar(
        'Saldo Oculto 👁️',
        'Seu saldo foi ocultado por segurança',
        backgroundColor: AppColors.primary.withOpacity(0.1),
        colorText: AppColors.primary,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    // Se está oculto, solicitar PIN para revelar
    setState(() => _isLoading = true);

    try {
      print('🔐 Solicitando PIN para revelar saldo...');
      
      final result = await Get.toNamed(
        AppRoutes.verifyPin,
        arguments: {
          'flow': 'show_balance',
          'title': 'Revelar Saldo',
          'description': 'Digite seu PIN para visualizar o saldo',
        },
      );

      if (result == true) {
        setState(() {
          _isBalanceVisible = true;
        });
        
        Get.snackbar(
          'Saldo Revelado! 👁️',
          'Seu saldo está agora visível',
          backgroundColor: AppColors.success,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
        
        // ✅ Auto-ocultar após 30 segundos
        Future.delayed(const Duration(seconds: 30), () {
          if (mounted && _isBalanceVisible) {
            setState(() {
              _isBalanceVisible = false;
            });
            
            Get.snackbar(
              'Saldo Auto-ocultado 🔒',
              'Por segurança, o saldo foi ocultado automaticamente',
              backgroundColor: AppColors.warning.withOpacity(0.1),
              colorText: AppColors.warning,
              snackPosition: SnackPosition.BOTTOM,
              duration: const Duration(seconds: 2),
            );
          }
        });
      }
    } catch (e) {
      print('❌ Erro ao solicitar PIN para saldo: $e');
      
      Get.snackbar(
        'Erro',
        'Não foi possível verificar o PIN',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// ✅ MÉTODOS HELPER
  String _formatCurrency(double value) {
    return value.toStringAsFixed(2).replaceAll('.', ',');
  }

  String _getStatusText() {
    if (_isLoading) {
      return 'Verificando...';
    } else if (_isBalanceVisible) {
      return 'Saldo visível • Auto-oculta em 30s';
    } else {
      return 'Saldo protegido por PIN';
    }
  }
}