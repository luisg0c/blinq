import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../services/auth_service.dart';
import '../services/transaction_service.dart';
import '../core/theme.dart';
import '../widgets/transaction_card.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({Key? key}) : super(key: key);

  static const String routeName = '/history';

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  bool _isLoading = true;
  List<TransactionModel> _transactions = [];
  String? _userId;
  String? _filterType;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final currentUser = await authService.getCurrentUserModel();

      if (currentUser != null) {
        _userId = currentUser.id;
        await _loadTransactions();
      }
    } catch (e) {
      debugPrint('Erro ao carregar dados: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadTransactions() async {
    if (_userId == null) return;

    try {
      final transactionService =
          Provider.of<TransactionService>(context, listen: false);
      List<TransactionModel> transactions;

      if (_filterType == 'Depósitos') {
        transactions = await transactionService.getTransactionsByType(
          _userId!,
          TransactionType.deposit,
        );
      } else if (_filterType == 'Transferências Enviadas') {
        transactions = await transactionService.getSentTransfers(_userId!);
      } else if (_filterType == 'Transferências Recebidas') {
        transactions = await transactionService.getReceivedTransfers(_userId!);
      } else {
        transactions = await transactionService.getAllTransactions(_userId!);
      }

      setState(() {
        _transactions = transactions;
      });
    } catch (e) {
      debugPrint('Erro ao carregar transações: $e');
    }
  }

  void _applyFilter(String? filter) {
    setState(() {
      _filterType = filter == 'Todos' ? null : filter;
    });
    _loadTransactions();
  }

  @override
  Widget build(BuildContext context) {
    final List<String> filterOptions = [
      'Todos',
      'Depósitos',
      'Transferências Enviadas',
      'Transferências Recebidas'
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Transações'),
        backgroundColor: AppColors.primary,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: _applyFilter,
            itemBuilder: (context) => filterOptions
                .map((filter) => PopupMenuItem<String>(
                      value: filter,
                      child: Text(filter),
                    ))
                .toList(),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: _loadData,
              color: AppColors.primary,
              child: _transactions.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _transactions.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final transaction = _transactions[index];
                        return TransactionCard(
                          transaction: transaction,
                          currentUserId: _userId ?? '',
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/transaction_details',
                              arguments: transaction,
                            );
                          },
                        );
                      },
                    ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: AppColors.textLight.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma transação encontrada',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              _filterType != null
                  ? 'Não há transações com o filtro aplicado.'
                  : 'Suas transações aparecerão aqui quando você realizar depósitos ou transferências.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textLight,
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (_filterType != null)
            TextButton.icon(
              onPressed: () {
                _applyFilter('Todos');
              },
              icon: Icon(
                Icons.filter_alt_off,
                color: AppColors.primary,
              ),
              label: Text(
                'Remover filtro',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
