// blinq/lib/presentation/controllers/home_controller.dart
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/transaction.dart' as domain;
import '../../domain/repositories/account_repository.dart';
import '../../domain/repositories/transaction_repository.dart';
import 'dart:async';

class HomeController extends GetxController {
  final AccountRepository _accountRepository;
  final TransactionRepository _transactionRepository;

  HomeController({
    required AccountRepository accountRepository,
    required TransactionRepository transactionRepository,
  }) : _accountRepository = accountRepository,
       _transactionRepository = transactionRepository;

  // Observables
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxDouble balance = 0.0.obs;
  final RxList<domain.Transaction> recentTransactions = <domain.Transaction>[].obs;

  // Stream subscriptions para dados em tempo real
  StreamSubscription<double>? _balanceSubscription;
  StreamSubscription<List<domain.Transaction>>? _transactionsSubscription;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  @override
  void onClose() {
    // Cancelar subscriptions ao fechar
    _balanceSubscription?.cancel();
    _transactionsSubscription?.cancel();
    super.onClose();
  }

  Future<void> loadData() async {
    try {
      isLoading.value = true;
      error.value = '';

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        error.value = 'Usuário não autenticado';
        return;
      }

      print('🔥 Configurando streams em tempo real para: ${currentUser.email}');

      // Garantir que a conta existe
      await _ensureAccountExists(currentUser.uid, currentUser.email!, currentUser.displayName);

      // STREAM DO SALDO EM TEMPO REAL
      _balanceSubscription?.cancel();
      _balanceSubscription = _accountRepository.watchBalance(currentUser.uid).listen(
        (newBalance) {
          balance.value = newBalance;
          print('💰 Saldo atualizado em tempo real: R\$ $newBalance');
        },
        onError: (e) {
          print('❌ Erro no stream do saldo: $e');
          error.value = 'Erro ao carregar saldo';
        },
      );

      // STREAM DAS TRANSAÇÕES EM TEMPO REAL
      _transactionsSubscription?.cancel();
      _transactionsSubscription = _transactionRepository.watchTransactionsByUser(currentUser.uid).listen(
        (transactions) {
          recentTransactions.value = transactions.take(5).toList();
          print('📋 ${transactions.length} transações carregadas em tempo real');
          
          // Log das transações para debug
          for (var tx in transactions.take(3)) {
            print('  📄 ${tx.type}: R\$ ${tx.amount} - ${tx.description}');
          }
        },
        onError: (e) {
          print('❌ Erro no stream das transações: $e');
          recentTransactions.value = [];
          error.value = 'Erro ao carregar transações';
        },
      );

    } catch (e) {
      error.value = 'Erro ao carregar dados: $e';
      print('❌ Erro geral: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Garantir que a conta existe no Firebase
  Future<void> _ensureAccountExists(String userId, String email, String? displayName) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final accountDoc = await firestore.collection('accounts').doc(userId).get();
      
      if (!accountDoc.exists) {
        print('🆕 Criando conta nova no Firebase para: $email');
        
        // Criar conta com estrutura corrigida
        await firestore.collection('accounts').doc(userId).set({
          'balance': 1000.0, // Saldo inicial de R$ 1.000
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'user': {
            'id': userId,
            'email': email,
            'name': displayName ?? 'Usuário Blinq',
          },
        });
        
        // Criar transação inicial de bônus
        await _createWelcomeTransaction(userId);
        
        print('✅ Conta criada com saldo inicial de R\$ 1.000');
      } else {
        print('✅ Conta já existe para: $email');
      }
    } catch (e) {
      print('❌ Erro ao criar/verificar conta: $e');
      throw e;
    }
  }

  /// Criar transação de bônus inicial
  Future<void> _createWelcomeTransaction(String userId) async {
    try {
      final welcomeTransaction = domain.Transaction(
        id: 'welcome_${DateTime.now().millisecondsSinceEpoch}',
        amount: 1000.0,
        date: DateTime.now(),
        description: 'Bônus de boas-vindas',
        type: 'bonus',
        counterparty: 'Blinq',
        status: 'completed',
      );

      await _transactionRepository.createTransaction(userId, welcomeTransaction);
      print('✅ Transação de boas-vindas criada');
    } catch (e) {
      print('❌ Erro ao criar transação de boas-vindas: $e');
    }
  }

  Future<void> refreshData() async {
    await loadData();
  }
}