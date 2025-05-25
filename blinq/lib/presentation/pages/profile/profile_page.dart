import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_colors.dart';
import '../../../routes/app_routes.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool notificationsEnabled = true;
  bool emailNotifications = false;
  bool biometricEnabled = false;
  bool darkModeEnabled = false;
  
  // ✅ LIMITES PROTEGIDOS POR PIN
  double dailyLimit = 1000.0;
  double transferLimit = 500.0;
  bool _limitsUnlocked = false; // Controla se os limites podem ser alterados
  
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      appBar: _buildFlatAppBar(context, isDark),
      body: _buildBody(context, user, isDark),
    );
  }

  PreferredSizeWidget _buildFlatAppBar(BuildContext context, bool isDark) {
    final textColor = isDark ? Colors.white : Colors.black87;
    
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Get.back(),
        icon: Icon(
          Icons.arrow_back_ios,
          color: textColor,
          size: 20,
        ),
      ),
      title: Text(
        'Perfil',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
      centerTitle: true,
      actions: [
        // Toggle tema
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: GestureDetector(
            onTap: () {
              Get.changeThemeMode(
                Get.isDarkMode ? ThemeMode.light : ThemeMode.dark,
              );
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F5),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: isDark 
                        ? Colors.black.withOpacity(0.3)
                        : Colors.black.withOpacity(0.1),
                    offset: const Offset(2, 2),
                    blurRadius: 6,
                  ),
                  BoxShadow(
                    color: isDark 
                        ? Colors.white.withOpacity(0.05)
                        : Colors.white,
                    offset: const Offset(-2, -2),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Icon(
                Get.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                color: isDark ? Colors.white70 : Colors.black54,
                size: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, User? user, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Header do usuário
          _buildNeomorphUserHeader(context, user, isDark),
          
          const SizedBox(height: 32),
          
          // Seção de Notificações
          _buildFlatSection(
            context,
            isDark,
            title: 'Notificações',
            children: [
              _buildSwitchTile(
                context,
                isDark,
                title: 'Notificações push',
                subtitle: 'Receber alertas de transações',
                value: notificationsEnabled,
                onChanged: (value) {
                  setState(() => notificationsEnabled = value);
                  _showFeedback(value ? 'Notificações ativadas ✅' : 'Notificações desativadas ❌');
                },
              ),
              _buildCheckboxTile(
                context,
                isDark,
                title: 'Relatórios por email',
                subtitle: 'Extrato mensal e resumos',
                value: emailNotifications,
                onChanged: (value) => setState(() => emailNotifications = value ?? false),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // ✅ SEÇÃO DE LIMITES PROTEGIDA POR PIN
          _buildProtectedLimitsSection(context, isDark),
          
          const SizedBox(height: 24),
          
          // Seção de Segurança
          _buildFlatSection(
            context,
            isDark,
            title: 'Segurança',
            children: [
              _buildSwitchTile(
                context,
                isDark,
                title: 'Autenticação biométrica',
                subtitle: 'Impressão digital ou Face ID',
                value: biometricEnabled,
                onChanged: (value) {
                  setState(() => biometricEnabled = value);
                  _showFeedback(value ? 'Biometria ativada 🔒' : 'Biometria desativada 🔓');
                },
              ),
              _buildActionTile(
                context,
                isDark,
                title: 'Alterar PIN de segurança',
                subtitle: 'Modificar PIN de transações',
                icon: Icons.security,
                onTap: () => Get.toNamed(AppRoutes.setupPin),
              ),
              _buildActionTile(
                context,
                isDark,
                title: 'Histórico de segurança',
                subtitle: 'Últimos acessos e atividades',
                icon: Icons.history,
                onTap: () => _showComingSoon('Histórico de Segurança'),
              ),
            ],
          ),
          
          const SizedBox(height: 40),
          
          // Botão de logout
          _buildNeomorphLogoutButton(context, isDark),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// ✅ SEÇÃO DE LIMITES PROTEGIDA POR PIN
  Widget _buildProtectedLimitsSection(BuildContext context, bool isDark) {
    return _buildFlatSection(
      context,
      isDark,
      title: 'Limites de Transação',
      titleAction: !_limitsUnlocked ? IconButton(
        icon: const Icon(Icons.lock, color: AppColors.primary, size: 20),
        onPressed: () => _requestPinForLimits(),
        tooltip: 'Clique para desbloquear alteração dos limites',
      ) : IconButton(
        icon: const Icon(Icons.lock_open, color: AppColors.success, size: 20),
        onPressed: () => _lockLimits(),
        tooltip: 'Clique para bloquear alteração dos limites',
      ),
      children: [
        // Status do bloqueio
        if (!_limitsUnlocked)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.warning.withOpacity(0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.lock, color: AppColors.warning, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Limites protegidos. Digite seu PIN para alterar.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.warning,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Sliders de limites
        _buildSliderTile(
          context,
          isDark,
          title: 'Limite diário',
          value: dailyLimit,
          min: 100,
          max: 5000,
          divisions: 49,
          format: (value) => 'R\$ ${value.round()}',
          onChanged: _limitsUnlocked ? (value) {
            setState(() => dailyLimit = value);
            _showFeedback('Limite diário alterado para R\$ ${value.round()}');
          } : null,
          isLocked: !_limitsUnlocked,
        ),
        
        _buildSliderTile(
          context,
          isDark,
          title: 'Limite por transferência',
          value: transferLimit,
          min: 50,
          max: 2000,
          divisions: 39,
          format: (value) => 'R\$ ${value.round()}',
          onChanged: _limitsUnlocked ? (value) {
            setState(() => transferLimit = value);
            _showFeedback('Limite por transferência alterado para R\$ ${value.round()}');
          } : null,
          isLocked: !_limitsUnlocked,
        ),

        // Info sobre os limites
        if (_limitsUnlocked)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.success.withOpacity(0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info, color: AppColors.success, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Alterações são salvas automaticamente e entram em vigor imediatamente.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.success,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// ✅ SOLICITAR PIN PARA ALTERAR LIMITES
  Future<void> _requestPinForLimits() async {
    print('🔐 Solicitando PIN para alterar limites...');
    
    try {
      final result = await Get.toNamed(
        AppRoutes.verifyPin,
        arguments: {
          'flow': 'change_limits',
          'title': 'Autorização Necessária',
          'description': 'Digite seu PIN para alterar os limites de transação',
        },
      );

      if (result == true) {
        setState(() => _limitsUnlocked = true);
        
        Get.snackbar(
          'Limites Desbloqueados! 🔓',
          'Você pode alterar seus limites agora',
          backgroundColor: AppColors.success,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );

        // Auto-bloquear após 2 minutos
        Future.delayed(const Duration(minutes: 2), () {
          if (mounted && _limitsUnlocked) {
            _lockLimits();
          }
        });
      }
    } catch (e) {
      print('❌ Erro ao solicitar PIN: $e');
      
      Get.snackbar(
        'Erro',
        'Não foi possível verificar o PIN',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// ✅ BLOQUEAR LIMITES NOVAMENTE
  void _lockLimits() {
    setState(() => _limitsUnlocked = false);
    
    Get.snackbar(
      'Limites Bloqueados 🔒',
      'Alteração de limites foi bloqueada novamente',
      backgroundColor: AppColors.primary,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // ✅ SLIDER TILE COM SUPORTE A BLOQUEIO
  Widget _buildSliderTile(
    BuildContext context,
    bool isDark, {
    required String title,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String Function(double) format,
    required ValueChanged<double>? onChanged,
    bool isLocked = false,
  }) {
    final textColor = isDark ? Colors.white : Colors.black87;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isLocked ? textColor.withOpacity(0.5) : textColor,
                    ),
                  ),
                  if (isLocked) ...[
                    const SizedBox(width: 8),
                    Icon(
                      Icons.lock,
                      size: 16,
                      color: AppColors.warning.withOpacity(0.7),
                    ),
                  ],
                ],
              ),
              Text(
                format(value),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isLocked ? AppColors.warning : AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: isLocked ? Colors.grey : AppColors.primary,
              inactiveTrackColor: isLocked 
                  ? Colors.grey.withOpacity(0.3)
                  : AppColors.primary.withOpacity(0.3),
              thumbColor: isLocked ? Colors.grey : AppColors.primary,
              overlayColor: isLocked 
                  ? Colors.grey.withOpacity(0.2)
                  : AppColors.primary.withOpacity(0.2),
              valueIndicatorColor: isLocked ? Colors.grey : AppColors.primary,
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              label: format(value),
              onChanged: isLocked ? null : onChanged,
            ),
          ),
        ],
      ),
    );
  }

  // ✅ SEÇÃO COM AÇÃO NO TÍTULO
  Widget _buildFlatSection(
    BuildContext context,
    bool isDark, {
    required String title,
    required List<Widget> children,
    Widget? titleAction,
  }) {
    final textColor = isDark ? Colors.white : Colors.black87;
    final backgroundColor = isDark ? const Color(0xFF252525) : const Color(0xFFFAFAFA);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              if (titleAction != null) titleAction,
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  // Manter os outros métodos existentes...
  Widget _buildNeomorphUserHeader(BuildContext context, User? user, bool isDark) {
    final textColor = isDark ? Colors.white : Colors.black87;
    final secondaryTextColor = isDark ? Colors.white70 : Colors.black54;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark 
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
            offset: const Offset(0, 4),
            blurRadius: 20,
          ),
          BoxShadow(
            color: isDark 
                ? Colors.white.withOpacity(0.03)
                : Colors.white,
            offset: const Offset(-4, -4),
            blurRadius: 15,
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar neomorfo
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary,
                  Color(0xFF5BC4A8),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  offset: const Offset(0, 4),
                  blurRadius: 15,
                ),
              ],
            ),
            child: Center(
              child: Text(
                user?.displayName?.substring(0, 1).toUpperCase() ?? 'U',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Text(
            user?.displayName ?? 'Usuário Blinq',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            user?.email ?? 'usuario@blinq.com',
            style: TextStyle(
              fontSize: 16,
              color: secondaryTextColor,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Badge verificado
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.success.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.verified,
                  color: AppColors.success,
                  size: 16,
                ),
                SizedBox(width: 6),
                Text(
                  'Conta Verificada',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context,
    bool isDark, {
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.white70 : Colors.black54;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: subtitleColor,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
            activeTrackColor: AppColors.primary.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxTile(
    BuildContext context,
    bool isDark, {
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.white70 : Colors.black54;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: subtitleColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context,
    bool isDark, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.white70 : Colors.black54;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: subtitleColor,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: subtitleColor,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNeomorphLogoutButton(BuildContext context, bool isDark) {
    return GestureDetector(
      onTap: () async {
        final confirm = await Get.dialog<bool>(
          AlertDialog(
            backgroundColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
            title: Text(
              'Confirmar logout',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            content: Text(
              'Tem certeza que deseja sair da sua conta?',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
              TextButton(
                onPressed: () => Get.back(result: true),
                child: const Text(
                  'Sair',
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            ],
          ),
        );
        
        if (confirm == true) {
          await FirebaseAuth.instance.signOut();
          Get.offAllNamed(AppRoutes.welcome);
        }
      },
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.error.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark 
                  ? Colors.black.withOpacity(0.2)
                  : Colors.black.withOpacity(0.05),
              offset: const Offset(0, 4),
              blurRadius: 12,
            ),
            BoxShadow(
              color: isDark 
                  ? Colors.white.withOpacity(0.02)
                  : Colors.white,
              offset: const Offset(-2, -2),
              blurRadius: 8,
            ),
          ],
        ),
        child: const Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.logout,
                color: AppColors.error,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Sair da conta',
                style: TextStyle(
                  color: AppColors.error,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ MÉTODOS HELPER
  void _showFeedback(String message) {
    Get.snackbar(
      'Configuração Alterada',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primary.withOpacity(0.1),
      colorText: AppColors.primary,
      duration: const Duration(seconds: 2),
    );
  }

  void _showComingSoon(String feature) {
    Get.snackbar(
      'Em Breve 🚧',
      '$feature estará disponível em uma próxima atualização',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.warning.withOpacity(0.1),
      colorText: AppColors.warning,
      duration: const Duration(seconds: 3),
    );
  }
}