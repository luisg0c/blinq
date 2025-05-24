import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import '../../../domain/entities/transaction.dart' as domain;
import '../../../domain/repositories/transaction_repository.dart';
import '../../../core/components/transaction_card.dart';
import '../../../core/theme/app_colors.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  final TransactionRepository _transactionRepository = Get.find<TransactionRepository>();
  
  List<domain.Transaction> _transactions = [];
  bool _isLoading = true;
  String? _error;
  StreamSubscription<List<domain.Transaction>>? _subscription;
  
  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }
  
  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
  
  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      final user = Get.find<FirebaseAuth>().currentUser;
      if (user == null) {
        setState(() {
          _error = 'Usuário não autenticado';
          _isLoading = false;
        });
        return;
      }
      
      // Iniciar a escuta de transações em tempo real
      _subscription?.cancel();
      _subscription = _transactionRepository
          .watchTransactionsByUser(user.uid)
          .listen((transactions) {
        setState(() {
          _transactions = transactions;
          _isLoading = false;
        });
      }, onError: (e) {
        setState(() {
          _error = 'Erro ao carregar transações: $e';
          _isLoading = false;
        });
      });
    } catch (e) {
      setState(() {
        _error = 'Erro inesperado: $e';
        _isLoading = false;
      });
    }
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
            onPressed: _loadTransactions,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }
  
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    
    if (_error != null) {
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
              _error!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadTransactions,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }
    
    if (_transactions.isEmpty) {
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
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Faça sua primeira transação para começar',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _loadTransactions,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _transactions.length,
        itemBuilder: (context, index) {
          final transaction = _transactions[index];
          return TransactionCard(
            transaction: transaction,
            onTap: () => _showTransactionDetails(transaction),
          );
        },
      ),
    );
  }
  
  void _showTransactionDetails(domain.Transaction transaction) {
    Get.dialog(
      AlertDialog(
        title: Text(
          transaction.isDeposit 
              ? 'Detalhes do Depósito'
              : 'Detalhes da Transferência',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow('ID:', transaction.id.substring(0, 8) + '...'),
            _detailRow('Tipo:', transaction.type),
            _detailRow('Valor:', 'R\$ ${transaction.amount.abs().toStringAsFixed(2)}'),
            _detailRow('Data:', _formatDate(transaction.date)),
            _detailRow('Descrição:', transaction.description),
            if (transaction.counterparty.isNotEmpty)
              _detailRow('Contraparte:', transaction.counterparty),
            _detailRow('Status:', transaction.status),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Fechar'),
          ),
          ElevatedButton(
            onPressed: () {
              // Aqui poderia implementar a geração do comprovante
              Get.back();
              Get.snackbar(
                'Comprovante',
                'Recurso disponível em breve',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text('Gerar Comprovante'),
          ),
        ],
      ),
    );
  }
  
  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} - ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}