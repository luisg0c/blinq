import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';
import '../../domain/models/transaction_model.dart';
import 'transaction_card_widget.dart';

class TransactionHistoryWidget extends StatelessWidget {
  final Stream<List<TransactionModel>> transactionsStream;
  final String userId;
  final bool isHistoryVisible;
  final Function onRequestUnlock;
  
  const TransactionHistoryWidget({
    Key? key,
    required this.transactionsStream,
    required this.userId,
    required this.isHistoryVisible,
    required this.onRequestUnlock,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<TransactionModel>>(
      stream: transactionsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SliverToBoxAdapter(
            child: SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        
        if (snapshot.hasError) {
          return SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Erro ao carregar transações: ${snapshot.error}'),
              ),
            ),
          );
        }
        
        final transactions = snapshot.data ?? [];
        
        if (transactions.isEmpty) {
          return SliverToBoxAdapter(
            child: _buildEmptyState(),
          );
        }
        
        // Verificar se o histórico está visível
        if (!isHistoryVisible) {
          return SliverToBoxAdapter(
            child: _buildBlurredState(transactions),
          );
        }
        
        // Quando o histórico está visível, usar SliverList
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (index >= transactions.length) {
                return null;
              }
              return TransactionCard(
                transaction: transactions[index],
                currentUserId: userId,
              );
            },
            childCount: transactions.length,
          ),
        );
      },
    );
  }
  
  // Estado vazio
  Widget _buildEmptyState() {
    return Container(
      height: 200,
      margin: const EdgeInsets.only(bottom: 20),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: isHistoryVisible 
        ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.history, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 16),
              const Text(
                'Nenhuma transação encontrada',
                style: TextStyle(
                  color: Colors.black54, 
                  fontSize: 16,
                ),
              ),
            ],
          )
        : GestureDetector(
            onTap: () => onRequestUnlock(),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _buildLockOverlay(),
            ),
          ),
    );
  }
  
  // Estado com blur - evitar problemas com Sliver usando SliverToBoxAdapter
  Widget _buildBlurredState(List<TransactionModel> transactions) {
    // Lista de widgets de transação (limitada a 10)
    final transactionWidgets = transactions
        .take(10) // Limitar a 10 para performance
        .map((tx) => TransactionCard(
              transaction: tx,
              currentUserId: userId,
            ))
        .toList();
    
    // Container único para todas as transações borradas
    return Container(
      height: 350, // Altura fixa para mostrar algumas transações
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: GestureDetector(
          onTap: () => onRequestUnlock(),
          child: Stack(
            children: [
              // Fundo com conteúdo borrado
              Positioned.fill(
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: Column(
                      children: transactionWidgets,
                    ),
                  ),
                ),
              ),
              
              // Overlay para bloquear interações e mostrar mensagem
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                  child: _buildLockOverlay(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Overlay do cadeado
  Widget _buildLockOverlay() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.lock_outline,
            size: 50,
            color: Colors.white.withOpacity(0.8),
          ),
          const SizedBox(height: 16),
          Text(
            'Toque para desbloquear o histórico',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 5,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}