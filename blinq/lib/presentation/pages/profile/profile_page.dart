import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_colors.dart';
import '../../../routes/app_routes.dart';

/// Switch, Checkbox, Slider implementados
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool notificationsEnabled = true;      // Switch
  bool emailNotifications = false;       // Checkbox  
  bool biometricEnabled = false;         // Switch
  bool darkModeEnabled = false;          // Switch
  double dailyLimit = 1000.0;           // Slider
  double transferLimit = 500.0;         // Slider
  double riskTolerance = 3.0;           // Slider
  
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil e Configurações'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildUserSection(user),
            const SizedBox(height: 24),
            _buildNotificationSection(),
            const SizedBox(height: 24),
            _buildLimitsSection(),
            const SizedBox(height: 24),
            _buildSecuritySection(),
            const SizedBox(height: 24),
            _buildPreferencesSection(),
            const SizedBox(height: 32),
            _buildLogoutButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserSection(User? user) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 35,
              backgroundColor: AppColors.primary,
              child: Text(
                user?.displayName?.substring(0, 1).toUpperCase() ?? 'U',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.displayName ?? 'Usuário Blinq',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? 'usuario@blinq.com',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Conta Verificada',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.success,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notificações',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Notificações push'),
              subtitle: const Text('Receber alertas de transações em tempo real'),
              value: notificationsEnabled,
              activeColor: AppColors.primary,
              onChanged: (value) {
                setState(() => notificationsEnabled = value);
                Get.snackbar(
                  'Notificações',
                  value ? 'Notificações ativadas ✅' : 'Notificações desativadas ❌',
                  snackPosition: SnackPosition.BOTTOM,
                  duration: const Duration(seconds: 2),
                );
              },
            ),
            
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Relatórios por email'),
              subtitle: const Text('Receber extrato mensal e resumos'),
              value: emailNotifications,
              activeColor: AppColors.primary,
              onChanged: (value) => setState(() => emailNotifications = value ?? false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLimitsSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Limites de Transação',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Text(
              'Limite diário: R\$ ${dailyLimit.round()}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Slider(
              value: dailyLimit,
              min: 100,
              max: 5000,
              divisions: 49,
              activeColor: AppColors.primary,
              inactiveColor: AppColors.primary.withOpacity(0.3),
              label: 'R\$ ${dailyLimit.round()}',
              onChanged: (value) => setState(() => dailyLimit = value),
            ),
            
            const SizedBox(height: 16),
            
            Text(
              'Limite por transferência: R\$ ${transferLimit.round()}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Slider(
              value: transferLimit,
              min: 50,
              max: 2000,
              divisions: 39,
              activeColor: AppColors.primary,
              inactiveColor: AppColors.primary.withOpacity(0.3),
              label: 'R\$ ${transferLimit.round()}',
              onChanged: (value) => setState(() => transferLimit = value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecuritySection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Segurança',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Autenticação biométrica'),
              subtitle: const Text('Usar impressão digital ou Face ID'),
              value: biometricEnabled,
              activeColor: AppColors.primary,
              onChanged: (value) {
                setState(() => biometricEnabled = value);
                Get.snackbar(
                  'Segurança',
                  value ? 'Biometria ativada 🔒' : 'Biometria desativada 🔓',
                  snackPosition: SnackPosition.BOTTOM,
                  duration: const Duration(seconds: 2),
                );
              },
            ),
            
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Alterar PIN de segurança'),
              subtitle: const Text('Modificar PIN de transações'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => Get.toNamed(AppRoutes.setupPin),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferencesSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Preferências',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Modo escuro'),
              subtitle: const Text('Interface com cores escuras'),
              value: darkModeEnabled,
              activeColor: AppColors.primary,
              onChanged: (value) => setState(() => darkModeEnabled = value),
            ),
            
            const SizedBox(height: 16),
            
            Text(
              'Tolerância a risco: ${_getRiskLabel(riskTolerance)}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Slider(
              value: riskTolerance,
              min: 1,
              max: 5,
              divisions: 4,
              activeColor: AppColors.primary,
              inactiveColor: AppColors.primary.withOpacity(0.3),
              label: _getRiskLabel(riskTolerance),
              onChanged: (value) => setState(() => riskTolerance = value),
            ),
          ],
        ),
      ),
    );
  }

  String _getRiskLabel(double value) {
    switch (value.round()) {
      case 1: return 'Muito Conservador';
      case 2: return 'Conservador';
      case 3: return 'Moderado';
      case 4: return 'Arrojado';
      case 5: return 'Muito Arrojado';
      default: return 'Moderado';
    }
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () async {
          // Confirmação antes do logout
          final confirm = await Get.dialog<bool>(
            AlertDialog(
              title: const Text('Confirmar logout'),
              content: const Text('Tem certeza que deseja sair da sua conta?'),
              actions: [
                TextButton(
                  onPressed: () => Get.back(result: false),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () => Get.back(result: true),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                  child: const Text('Sair'),
                ),
              ],
            ),
          );
          
          if (confirm == true) {
            await FirebaseAuth.instance.signOut();
            Get.offAllNamed(AppRoutes.welcome);
          }
        },
        icon: const Icon(Icons.logout),
        label: const Text('Sair da conta'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.error,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}