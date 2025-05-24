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
        _error = 'Erro ao carregar transações: \$e';
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
                          onTap: () => _showDetails(_transactions[i]),
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

  void _showDetails(domain.Transaction tx) {
    Get.dialog(
      AlertDialog(
        title: Text(
          tx.isDeposit ? 'Detalhes do Depósito' : 'Detalhes da Transferência',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _row('ID:', '\${tx.id.substring(0, 8)}...'),
            _row('Tipo:', tx.type),
            _row('Valor:', 'R\$ \${tx.amount.abs().toStringAsFixed(2)}'),
            _row('Data:', _format(tx.date)),
            _row('Descrição:', tx.description),
            if (tx.counterparty.isNotEmpty) _row('Contraparte:', tx.counterparty),
            _row('Status:', tx.status),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Fechar'),
          ),
          ElevatedButton(
            onPressed: () {
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

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _format(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} - ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}