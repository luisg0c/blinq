// lib/presentation/controllers/home_controller.dart
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

  // Stream subscriptions
  StreamSubscription<double>? _balanceSubscription;
  StreamSubscription<List<domain.Transaction>>? _transactionsSubscription;

  @override
  void onInit() {
    super.onInit();
    _initializeData();
  }

  @override
  void onClose() {
    _balanceSubscription?.cancel();
    _transactionsSubscription?.cancel();
    super.onClose();
  }

  Future<void> _initializeData() async {
    try {
      isLoading.value = true;
      error.value = '';

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        error.value = 'Usuário não autenticado';
        return;
      }

      print('🏠 HomeController inicializando para: ${currentUser.email}');

      // Garantir que a conta existe
      await _ensureAccountExists(currentUser.uid, currentUser.email!, currentUser.displayName);

      // Configurar streams em tempo real
      _setupRealTimeStreams(currentUser.uid);

    } catch (e) {
      error.value = 'Erro ao carregar dados: $e';
      print('❌ Erro na inicialização: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _setupRealTimeStreams(String userId) {
    // Stream do saldo
    _balanceSubscription?.cancel();
    _balanceSubscription = _accountRepository.watchBalance(userId).listen(
      (newBalance) {
        balance.value = newBalance;
        print('💰 Saldo atualizado: R\$ $newBalance');
      },
      onError: (e) {
        print('❌ Erro no stream do saldo: $e');
        error.value = 'Erro ao carregar saldo';
      },
    );

    // Stream das transações
    _transactionsSubscription?.cancel();
    _transactionsSubscription = _transactionRepository.watchTransactionsByUser(userId).listen(
      (transactions) {
        recentTransactions.value = transactions.take(5).toList();
        print('📋 ${transactions.length} transações carregadas');
      },
      onError: (e) {
        print('❌ Erro no stream das transações: $e');
        recentTransactions.value = [];
        error.value = 'Erro ao carregar transações';
      },
    );
  }

  Future<void> _ensureAccountExists(String userId, String email, String? displayName) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final accountDoc = await firestore.collection('accounts').doc(userId).get();
      
      if (!accountDoc.exists) {
        print('🆕 Criando conta para: $email');
        
        await firestore.collection('accounts').doc(userId).set({
          'balance': 1000.0, // Saldo inicial
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'user': {
            'id': userId,
            'email': email,
            'name': displayName ?? 'Usuário Blinq',
          },
        });
        
        await _createWelcomeTransaction(userId);
        print('✅ Conta criada com saldo inicial');
      }
    } catch (e) {
      print('❌ Erro ao criar/verificar conta: $e');
      throw e;
    }
  }

  Future<void> _createWelcomeTransaction(String userId) async {
    try {
      final welcomeTransaction = domain.Transaction(
        id: 'welcome_${DateTime.now().millisecondsSinceEpoch}',
        amount: 1000.0,
        date: DateTime.now(),
        description: 'Bônus de boas-vindas - Bem-vindo ao Blinq! 🎉',
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
    print('🔄 Refreshing data...');
    await _initializeData();
  }

  // Métodos para navegação
  void goToDeposit() {
    Get.toNamed('/deposit');
  }

  void goToTransfer() {
    Get.toNamed('/transfer');
  }

  void goToTransactions() {
    Get.toNamed('/transactions');
  }

  void goToProfile() {
    Get.toNamed('/profile');
  }

  void goToExchangeRates() {
    Get.toNamed('/exchange-rates');
  }

  // Método para logout
  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      Get.offAllNamed('/welcome');
    } catch (e) {
      print('❌ Erro no logout: $e');
    }
  }
}