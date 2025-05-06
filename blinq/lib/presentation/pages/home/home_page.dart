import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import '../../core/constants/colors.dart';
import '../../core/utils/formatters.dart';
import '../controllers/home_controller.dart';
import '../controllers/auth_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late HomeController _homeController;
  late AuthController _authController;

  @override
  void initState() {
    super.initState();
    _homeController = Get.find<HomeController>();
    _authController = Get.find<AuthController>();

    // Definir a cor da barra de status
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: AppColors.primary,
      statusBarIconBrightness: Brightness.dark,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildBalanceCard(),
            const SizedBox(height: 20),
            _buildActionButtons(),
            const SizedBox(height: 30),
            _buildTransactionHistory(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // Cabeçalho verde com saudação
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.primary,
      ),
      child: Obx(() {
        final userName = _authController.currentUser.value?.name ?? "usuário";
        final firstName = userName.split(' ')[0];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Ícone de perfil
                const Icon(
                  Icons.person_outline,
                  color: AppColors.textDark,
                  size: 30,
                ),

                // Ícones do lado direito
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.help_outline,
                        color: AppColors.textDark,
                      ),
                      onPressed: () {
                        // Navegar para ajuda
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.search,
                        color: AppColors.textDark,
                      ),
                      onPressed: () {
                        // Abrir busca
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.settings,
                        color: AppColors.textDark,
                      ),
                      onPressed: () {
                        // Navegar para configurações
                      },
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(height: 30),
            Text(
              "Olá de novo, $firstName!",
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 10),
          ],
        );
      }),
    );
  }

  // Card com o saldo disponível
  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: AppColors.background,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Saldo disponível",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textLight,
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppColors.textLight.withOpacity(0.7),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Obx(() {
            final balance = _homeController.balance.value;
            final showBalance = _homeController.showBalance.value;

            return GestureDetector(
              onTap: _homeController.toggleBalanceVisibility,
              child: Text(
                showBalance ? Formatters.formatCurrency(balance) : "R\$ •••••",
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textLight,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // Botões de ação (Depositar, Transferir, Investir)
  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            icon: Icons.add,
            label: 'Depositar',
            onTap: () => _homeController.navigateToDeposit(),
          ),
          _buildActionButton(
            icon: Icons.send,
            label: 'Transferir',
            onTap: () => _homeController.navigateToTransfer(),
          ),
          _buildActionButton(
            icon: Icons.show_chart,
            label: 'Investir',
            onTap: () {
              // Navegar para investimentos (funcionalidade futura)
              Get.snackbar(
                'Em breve',
                'Funcionalidade de investimentos em desenvolvimento!',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                colorText: AppColors.primary,
              );
            },
          ),
        ],
      ),
    );
  }

  // Botão de ação circular
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.iconBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppColors.textLight,
              size: 30,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }

  // Histórico de transações
  Widget _buildTransactionHistory() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Extrato",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textLight,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                final transactions = _homeController.recentTransactions;

                if (transactions.isEmpty) {
                  return _buildEmptyTransactions();
                }

                return ListView.builder(
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        transaction.isDeposit
                            ? 'Depósito'
                            : transaction.isTransfer
                                ? transaction.senderId ==
                                        _authController.currentUser.value?.id
                                    ? 'Transferência enviada'
                                    : 'Transferência recebida'
                                : 'Transação',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textLight,
                        ),
                      ),
                      subtitle: Text(
                        Formatters.formatRelativeDate(transaction.timestamp),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textLight.withOpacity(0.7),
                        ),
                      ),
                      trailing: Text(
                        Formatters.formatTransactionValue(
                          transaction.amount,
                          transaction.type,
                          transaction.senderId,
                          _authController.currentUser.value?.id ?? '',
                        ),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: transaction.isDeposit ||
                                  (transaction.isTransfer &&
                                      transaction.receiverId ==
                                          _authController.currentUser.value?.id)
                              ? AppColors.success
                              : AppColors.error,
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // Widget para mostrar quando não há transações
  Widget _buildEmptyTransactions() {
    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: AppColors.textLight.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            "Sem transações ainda",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textLight.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Faça seu primeiro depósito ou transferência",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textLight.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  // Barra de navegação inferior
  Widget _buildBottomNavBar() {
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(
            color: AppColors.divider,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavItem(
            icon: Icons.logout,
            onTap: () {
              _authController.signOut();
            },
          ),
          _buildNavItem(
            icon: Icons.shopping_cart_outlined,
            onTap: () {
              // Navegar para marketplace/produtos
              Get.snackbar(
                'Em breve',
                'Marketplace será implementado em breve!',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                colorText: AppColors.primary,
              );
            },
          ),
        ],
      ),
    );
  }

  // Item da barra de navegação
  Widget _buildNavItem({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 28,
          ),
        ),
      ),
    );
  }
}
