import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../services/account_service.dart';
import '../services/transaction_service.dart';
import '../models/transaction.dart';
import '../models/account.dart';
import '../models/user.dart';
import '../core/theme.dart';
import '../utils/formatters.dart';
import '../widgets/transaction_card.dart';
import '../widgets/balance_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  static const String routeName = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();
  final _accountService = AccountService();
  final _transactionService = TransactionService();
  bool _isLoading = true;
  User? _currentUser;
  Account? _account;
  List<Transaction> _recentTransactions = [];
  bool _showBalance = true;

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
      _currentUser = await _authService.getCurrentUserModel();

      if (_currentUser != null) {
        _account = await _accountService.getAccount(_currentUser!.id);
        _recentTransactions = await _transactionService.getRecentTransactions(
            _currentUser!.id, 5);
      }
    } catch (e) {
      print('Erro ao carregar dados: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _toggleShowBalance() {
    setState(() {
      _showBalance = !_showBalance;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: _loadData,
              color: AppColors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(24),
                          bottomRight: Radius.circular(24),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // User greeting
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Olá, ${_currentUser?.name.split(' ')[0] ?? 'Usuário'}',
                                    style: GoogleFonts.lexend(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.text,
                                    ),
                                  ),
                                  Text(
                                    'Bem-vindo de volta',
                                    style: GoogleFonts.lexend(
                                      fontSize: 14,
                                      color: AppColors.text.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                              // Profile avatar or icon
                              GestureDetector(
                                onTap: () {
                                  // Navigate to profile
                                  Navigator.pushNamed(context, '/profile');
                                },
                                child: CircleAvatar(
                                  backgroundColor: AppColors.surface,
                                  radius: 24,
                                  child: Text(
                                    _currentUser?.name
                                            .substring(0, 1)
                                            .toUpperCase() ??
                                        'U',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 30),

                          // Balance Card
                          BalanceCard(
                            balance: _account?.balance ?? 0.0,
                            isVisible: _showBalance,
                            onToggleVisibility: _toggleShowBalance,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Quick Actions
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'Ações Rápidas',
                        style: GoogleFonts.lexend(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Action Buttons
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildActionButton(
                            icon: Icons.add_rounded,
                            label: 'Depositar',
                            onTap: () {
                              Navigator.pushNamed(context, '/deposit');
                            },
                          ),
                          _buildActionButton(
                            icon: Icons.arrow_forward,
                            label: 'Transferir',
                            onTap: () {
                              Navigator.pushNamed(context, '/transfer');
                            },
                          ),
                          _buildActionButton(
                            icon: Icons.history,
                            label: 'Extrato',
                            onTap: () {
                              Navigator.pushNamed(context, '/history');
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Recent Transactions
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Transações Recentes',
                            style: GoogleFonts.lexend(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.text,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/history');
                            },
                            child: Text(
                              'Ver todas',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Transactions List
                    _recentTransactions.isEmpty
                        ? _buildEmptyTransactions()
                        : ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: _recentTransactions.length,
                            itemBuilder: (context, index) {
                              final transaction = _recentTransactions[index];
                              return TransactionCard(
                                transaction: transaction,
                                currentUserId: _currentUser?.id ?? '',
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

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

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
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: AppColors.text,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTransactions() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
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
              'Sem transações recentes',
              style: GoogleFonts.lexend(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Suas transações aparecerão aqui',
              style: GoogleFonts.lexend(
                fontSize: 14,
                color: AppColors.textLight.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
