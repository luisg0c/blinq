// lib/presentation/pages/transactions/transactions_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../domain/entities/transaction.dart' as domain;
import '../../../domain/repositories/transaction_repository.dart';
import '../../../core/components/transaction_card.dart';
import '../../../core/theme/app_colors.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({Key? key}) : super(key: key);

  @override
  _TransactionsPageState createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  final TransactionRepository _repository = Get.find<TransactionRepository>();
  StreamSubscription<List<domain.Transaction>>? _subscription;
  List<domain.Transaction> _transactions = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _startListening() {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _error = 'Usuário não autenticado';
        _isLoading = false;
      });
      return;
    }

    _subscription?.cancel();
    _subscription = _repository
        .watchTransactionsByUser(user.uid)
        .listen((list) {
      setState(() {
        _transactions = list;
        _isLoading = false;
      });
    }, onError: (e) {
      setState(() {
        _error = 'Erro ao carregar transações: $e';
        _isLoading = false;
      });
    });
  }

  Future<void> _refresh() async {
    _subscription?.cancel();
    _startListening();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Transações'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refresh(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _error != null
              ? _buildError()
              : _transactions.isEmpty
                  ? _buildEmpty()
                  : RefreshIndicator(
                      onRefresh: _refresh,
                      color: AppColors.primary,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: _transactions.length,
                        itemBuilder: (ctx, i) => TransactionCard(
                          transaction: _transactions[i],
                          onTap: () => _showTransactionDetails(_transactions[i]),
                        ),
                      ),
                    ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            'Não foi possível carregar as transações',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? '',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
            label: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma transação encontrada',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Faça sua primeira transação para começar',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  // ✅ MODAL DE DETALHES CORRIGIDO
  void _showTransactionDetails(domain.Transaction transaction) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    Get.dialog(
      AlertDialog(
        backgroundColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          _getTransactionTitle(transaction),
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('ID:', _getShortId(transaction.id), isDark),
            _buildDetailRow('Tipo:', _getTransactionTypeText(transaction.type), isDark),
            _buildDetailRow('Valor:', _formatCurrency(transaction.amount.abs()), isDark),
            _buildDetailRow('Data:', _formatFullDate(transaction.date), isDark),
            _buildDetailRow('Descrição:', transaction.description, isDark),
            if (transaction.counterparty.isNotEmpty)
              _buildDetailRow('Contraparte:', transaction.counterparty, isDark),
            _buildDetailRow('Status:', _getStatusText(transaction.status), isDark),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Fechar', style: TextStyle(color: AppColors.primary)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Comprovante',
                'Recurso disponível em breve',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppColors.warning.withOpacity(0.1),
                colorText: AppColors.warning,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Gerar Comprovante',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ MÉTODOS HELPER PARA FORMATAÇÃO CORRETA

  String _getTransactionTitle(domain.Transaction transaction) {
    switch (transaction.type.toLowerCase()) {
      case 'deposit':
        return 'Detalhes do Depósito';
      case 'transfer':
        return transaction.amount > 0 ? 'Transferência Recebida' : 'Transferência Enviada';
      case 'receive':
        return 'Transferência Recebida';
      default:
        return 'Detalhes da Transação';
    }
  }

  String _getShortId(String id) {
    return id.length > 8 ? '${id.substring(0, 8)}...' : id;
  }

  String _getTransactionTypeText(String type) {
    switch (type.toLowerCase()) {
      case 'deposit':
        return 'Depósito';
      case 'transfer':
        return 'Transferência';
      case 'receive':
        return 'Recebimento';
      default:
        return type.toUpperCase();
    }
  }

  String _formatCurrency(double amount) {
    return 'R\$ ${amount.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  String _formatFullDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    
    return '$day/$month/$year - $hour:$minute';
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return 'Concluído';
      case 'pending':
        return 'Pendente';
      case 'failed':
        return 'Falhou';
      case 'cancelled':
        return 'Cancelado';
      default:
        return status;
    }
  }

  Widget _buildDetailRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white70 : Colors.black54,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}