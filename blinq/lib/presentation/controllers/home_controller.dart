import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/account_repository.dart';
import '../../data/models/user_model.dart';
import '../../data/models/transaction_model.dart';
import '../../core/utils/logger.dart';
import 'transaction_controller.dart';
import 'auth_controller.dart';

/// Controlador para a página principal (home) do aplicativo
class HomeController extends GetxController with GetSingleTickerProviderStateMixin {
  final AuthController _authController;
  final TransactionController _transactionController;
  final AuthRepository _authRepository;
  final AccountRepository _accountRepository;
  final AppLogger _logger = AppLogger('HomeController');
  
  late TabController tabController;
  
  // Observables
  final RxInt currentTabIndex = 0.obs;
  final RxBool isLoadingData = false.obs;
  final RxString error = ''.obs;
  final RxBool showBalance = true.obs;
  final RxBool isHistoryVisible = false.obs;
  final RxList<TransactionModel> recentTransactions = <TransactionModel>[].obs;
  final RxInt recentTransactionsLimit = 5.obs;
  
  // Informações do usuário
  Rx<UserModel?> get currentUser => _authController.currentUser;
  RxDouble get balance => _transactionController.balance;
  RxList<TransactionModel> get transactions => _transactionController.transactions;
  RxBool get isLoading => _transactionController.isLoading;
  
  // Construtor com injeção de dependências
  HomeController(
    this._authController,
    this._transactionController,
    this._authRepository,
    this._accountRepository,
  );
  
  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 3, vsync: this);
    tabController.addListener(_handleTabChange);
    
    // Inicializar dados
    _initUserData();
  }
  
  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
  
  /// Manipula mudanças de tab
  void _handleTabChange() {
    currentTabIndex.value = tabController.index;
  }
  
  /// Inicializa dados do usuário
  Future<void> _initUserData() async {
    if (currentUser.value == null) {
      await _authController.reloadUser();
    }
    
    if (currentUser.value != null) {
      await _loadUserData(currentUser.value!.id);
    } else {
      _logger.warn('Tentativa de carregar dados sem usuário autenticado');
    }
  }
  
  /// Carrega dados do usuário
  Future<void> _loadUserData(String userId) async {
    try {
      isLoadingData.value = true;
      
      // Inicializar dados de transação
      await _transactionController.initUserData(userId);
      
      // Carregar apenas transações recentes para a página inicial
      await _loadRecentTransactions(userId);
      
      _logger.info('Dados do usuário carregados: $userId');
    } catch (e) {
      _logger.error('Erro ao carregar dados do usuário', e);
      error.value = 'Erro ao carregar seus dados';
    } finally {
      isLoadingData.value = false;
    }
  }
  
  /// Carrega transações recentes
  Future<void> _loadRecentTransactions(String userId) async {
    try {
      recentTransactions.assignAll(transactions.take(recentTransactionsLimit.value).toList());
      _logger.info('Transações recentes carregadas: ${recentTransactions.length}');
    } catch (e) {
      _logger.error('Erro ao carregar transações recentes', e);
    }
  }
  
  /// Alterna visibilidade do saldo
  void toggleBalanceVisibility() {
    showBalance.value = !showBalance.value;
  }
  
  /// Alterna visibilidade do histórico completo
  Future<void> toggleHistoryVisibility(BuildContext context) async {
    if (isHistoryVisible.value) {
      isHistoryVisible.value = false;
    } else {
      final userId = currentUser.value?.id;
      if (userId == null) return;
      
      // Verificar se o usuário possui senha de transação antes de mostrar histórico
      final hasPassword = await _accountRepository.hasTransactionPassword(userId);
      
      if (!hasPassword) {
        // Se não tem senha, exibe uma mensagem
        Get.snackbar(
          'Senha necessária',
          'Você precisa criar uma senha de transação antes de visualizar o histórico completo.',
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(8),
        );
        return;
      }
      
      // Solicitar validação de senha
      final isValid = await _promptForPasswordValidation(context, userId);
      
      if (isValid) {
        isHistoryVisible.value = true;
      }
    }
  }
  
  /// Solicita e valida a senha de transação
  Future<bool> _promptForPasswordValidation(BuildContext context, String userId) async {
    final passwordController = TextEditingController();
    
    try {
      final result = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Senha de Transação'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Digite sua senha de transação para visualizar o histórico completo:'),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                obscureText: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Senha',
                  counterText: '',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final password = passwordController.text.trim();
                if (password.isEmpty) return;
                
                final isValid = await _accountRepository.validateTransactionPassword(
                  userId,
                  password,
                );
                
                Navigator.of(context).pop(isValid);
              },
              child: const Text('Confirmar'),
            ),
          ],
        ),
      );
      
      return result ?? false;
    } finally {
      passwordController.dispose();
    }
  }
  
  /// Navega para a tela de depósito
  void navigateToDeposit() {
    Get.toNamed('/deposit');
  }
  
  /// Navega para a tela de transferência
  void navigateToTransfer() {
    Get.toNamed('/transfer');
  }
  
  /// Navega para a tela de histórico de transações
  void navigateToHistory() {
    Get.toNamed('/transactions');
  }
  
  /// Navega para a tela de perfil
  void navigateToProfile() {
    Get.toNamed('/profile');
  }
  
  /// Realiza o logout do usuário
  Future<void> logout() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Sair'),
        content: const Text('Tem certeza que deseja sair da sua conta?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      await _authController.signOut();
    }
  }
  
  /// Atualiza dados do usuário (pull-to-refresh)
  Future<void> refreshData() async {
    if (currentUser.value != null) {
      await _loadUserData(currentUser.value!.id);
    }
  }
  
  /// Calcula estatísticas de transações por tipo
  Map<String, double> getTransactionStats() {
    double totalDeposits = 0;
    double totalSent = 0;
    double totalReceived = 0;
    
    final userId = currentUser.value?.id;
    if (userId == null) return {
      'deposits': 0,
      'sent': 0,
      'received': 0,
    };
    
    for (final transaction in transactions) {
      if (transaction.type == 'deposit') {
        totalDeposits += transaction.amount;
      } else if (transaction.type == 'transfer') {
        if (transaction.senderId == userId) {
          totalSent += transaction.amount;
        } else if (transaction.receiverId == userId) {
          totalReceived += transaction.amount;
        }
      }
    }
    
    return {
      'deposits': totalDeposits,
      'sent': totalSent,
      'received': totalReceived,
    };
  }
}