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

  // ✅ CONTROLE DE USUÁRIO ATUAL
  String? _currentUserId;
  StreamSubscription<double>? _balanceSubscription;
  StreamSubscription<List<domain.Transaction>>? _transactionsSubscription;

  @override
  void onInit() {
    super.onInit();
    _initializeData();
  }

  @override
  void onClose() {
    print('🗑️ HomeController: Limpando recursos...');
    _cancelSubscriptions();
    _clearUserData();
    super.onClose();
  }

  /// ✅ INICIALIZAÇÃO SEGURA COM VERIFICAÇÃO DE USUÁRIO
  Future<void> _initializeData() async {
    try {
      isLoading.value = true;
      error.value = '';

      // ✅ VERIFICAR USUÁRIO ATUAL
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        error.value = 'Usuário não autenticado';
        return;
      }

      // ✅ VERIFICAR SE É UM NOVO USUÁRIO
      if (_currentUserId != currentUser.uid) {
        print('👤 Novo usuário detectado: ${currentUser.email}');
        print('   Usuário anterior: $_currentUserId');
        print('   Usuário atual: ${currentUser.uid}');
        
        // ✅ LIMPAR DADOS DO USUÁRIO ANTERIOR
        await _switchUser(currentUser.uid, currentUser.email!);
      }

      print('🏠 HomeController inicializando para: ${currentUser.email}');

      // ✅ GARANTIR QUE A CONTA EXISTE
      await _ensureAccountExists(currentUser.uid, currentUser.email!, currentUser.displayName);

      // ✅ CONFIGURAR STREAMS APENAS PARA O USUÁRIO ATUAL
      _setupRealTimeStreams(currentUser.uid);

    } catch (e) {
      error.value = 'Erro ao carregar dados: $e';
      print('❌ Erro na inicialização: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ TROCAR USUÁRIO E LIMPAR DADOS ANTERIORES
  Future<void> _switchUser(String newUserId, String newUserEmail) async {
    print('🔄 Trocando usuário...');
    print('   De: $_currentUserId');
    print('   Para: $newUserId ($newUserEmail)');

    // ✅ CANCELAR STREAMS ANTERIORES
    _cancelSubscriptions();

    // ✅ LIMPAR DADOS DO USUÁRIO ANTERIOR
    _clearUserData();

    // ✅ DEFINIR NOVO USUÁRIO
    _currentUserId = newUserId;
    
    print('✅ Usuário trocado com sucesso');
  }

  /// ✅ CANCELAR TODAS AS SUBSCRIPTIONS
  void _cancelSubscriptions() {
    print('🛑 Cancelando subscriptions...');
    
    _balanceSubscription?.cancel();
    _balanceSubscription = null;
    
    _transactionsSubscription?.cancel();
    _transactionsSubscription = null;
    
    print('✅ Subscriptions canceladas');
  }

  /// ✅ LIMPAR DADOS DO USUÁRIO
  void _clearUserData() {
    print('🧹 Limpando dados do usuário...');
    
    balance.value = 0.0;
    recentTransactions.clear();
    error.value = '';
    
    print('✅ Dados limpos');
  }

  /// ✅ CONFIGURAR STREAMS COM VERIFICAÇÃO DE USUÁRIO
  void _setupRealTimeStreams(String userId) {
    print('👀 Configurando streams para: $userId');

    // ✅ VERIFICAR SE É O USUÁRIO CORRETO
    if (_currentUserId != userId) {
      print('⚠️ UserId não confere! Atual: $_currentUserId, Solicitado: $userId');
      return;
    }

    // ✅ STREAM DO SALDO
    _balanceSubscription?.cancel();
    _balanceSubscription = _accountRepository.watchBalance(userId).listen(
      (newBalance) {
        // ✅ VERIFICAR SE AINDA É O USUÁRIO CORRETO
        if (_currentUserId == userId) {
          balance.value = newBalance;
          print('💰 Saldo atualizado para $userId: R\$ $newBalance');
        } else {
          print('⚠️ Saldo ignorado - usuário mudou');
        }
      },
      onError: (e) {
        print('❌ Erro no stream do saldo: $e');
        if (_currentUserId == userId) {
          error.value = 'Erro ao carregar saldo';
        }
      },
    );

    // ✅ STREAM DAS TRANSAÇÕES
    _transactionsSubscription?.cancel();
    _transactionsSubscription = _transactionRepository.watchTransactionsByUser(userId).listen(
      (transactions) {
        // ✅ VERIFICAR SE AINDA É O USUÁRIO CORRETO
        if (_currentUserId == userId) {
          recentTransactions.value = transactions.take(5).toList();
          print('📋 ${transactions.length} transações carregadas para $userId');
          
          // ✅ LOG DAS PRIMEIRAS TRANSAÇÕES PARA DEBUG
          for (var tx in transactions.take(3)) {
            print('  📄 ${tx.type}: R\$ ${tx.amount} - ${tx.description}');
          }
        } else {
          print('⚠️ Transações ignoradas - usuário mudou');
        }
      },
      onError: (e) {
        print('❌ Erro no stream das transações: $e');
        if (_currentUserId == userId) {
          recentTransactions.value = [];
          error.value = 'Erro ao carregar transações';
        }
      },
    );

    print('✅ Streams configurados para $userId');
  }

  /// ✅ GARANTIR QUE A CONTA EXISTE (SEM ALTERAR OUTRAS CONTAS)
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
        print('✅ Conta criada com saldo inicial para $userId');
      } else {
        print('✅ Conta já existe para: $userId');
      }
    } catch (e) {
      print('❌ Erro ao criar/verificar conta: $e');
      throw e;
    }
  }

  /// ✅ CRIAR TRANSAÇÃO DE BOAS-VINDAS ESPECÍFICA DO USUÁRIO
  Future<void> _createWelcomeTransaction(String userId) async {
    try {
      final welcomeTransaction = domain.Transaction(
        id: 'welcome_${userId}_${DateTime.now().millisecondsSinceEpoch}',
        amount: 1000.0,
        date: DateTime.now(),
        description: 'Bônus de boas-vindas - Bem-vindo ao Blinq! 🎉',
        type: 'bonus',
        counterparty: 'Blinq',
        status: 'completed',
      );

      await _transactionRepository.createTransaction(userId, welcomeTransaction);
      print('✅ Transação de boas-vindas criada para $userId');
    } catch (e) {
      print('❌ Erro ao criar transação de boas-vindas: $e');
    }
  }

  /// ✅ REFRESH COM VERIFICAÇÃO DE USUÁRIO
  Future<void> refreshData() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      error.value = 'Usuário não autenticado';
      return;
    }

    // ✅ VERIFICAR SE É O MESMO USUÁRIO
    if (_currentUserId != currentUser.uid) {
      print('👤 Usuário mudou durante refresh');
      await _initializeData();
      return;
    }

    print('🔄 Refreshing data para: ${currentUser.email}');
    await _initializeData();
  }

  /// ✅ MÉTODOS DE NAVEGAÇÃO (SEM ALTERAÇÃO)
  void goToDeposit() => Get.toNamed('/deposit');
  void goToTransfer() => Get.toNamed('/transfer');
  void goToTransactions() => Get.toNamed('/transactions');
  void goToProfile() => Get.toNamed('/profile');
  void goToExchangeRates() => Get.toNamed('/exchange-rates');

  /// ✅ LOGOUT SEGURO COM LIMPEZA
  Future<void> logout() async {
    try {
      print('👋 Fazendo logout do usuário: $_currentUserId');
      
      // ✅ LIMPAR TUDO ANTES DO LOGOUT
      _cancelSubscriptions();
      _clearUserData();
      _currentUserId = null;
      
      await FirebaseAuth.instance.signOut();
      Get.offAllNamed('/welcome');
      
      print('✅ Logout realizado e dados limpos');
    } catch (e) {
      print('❌ Erro no logout: $e');
    }
  }

  /// ✅ DEBUG - VERIFICAR ESTADO ATUAL
  void debugCurrentState() {
    print('🔍 DEBUG - Estado atual:');
    print('   Current User ID: $_currentUserId');
    print('   Firebase User: ${FirebaseAuth.instance.currentUser?.uid}');
    print('   Balance: ${balance.value}');
    print('   Transactions: ${recentTransactions.length}');
    print('   Error: ${error.value}');
  }
}