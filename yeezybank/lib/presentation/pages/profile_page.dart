import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/services/auth_service.dart';
import '../../data/firebase_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();
    final firebaseService = Get.find<FirebaseService>();
    final user = authService.getCurrentUser();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil', style: AppTextStyles.appBarTitle),
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textColor),
      ),
      backgroundColor: AppColors.backgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(user?.email ?? 'Usuário Anônimo'),
            const SizedBox(height: 32),
            _buildAccountSection(authService),
            const SizedBox(height: 24),
            _buildSettingsSection(context),
            const Spacer(),
            _buildLogoutButton(authService),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(String email) {
    return Row(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: AppColors.primaryColor.withOpacity(0.1),
          child: const Icon(
            Icons.person,
            size: 40,
            color: AppColors.primaryColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Olá,', style: AppTextStyles.body),
              Text(email, style: AppTextStyles.title),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccountSection(AuthService authService) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.dividerColor),
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(
              Icons.email_outlined,
              color: AppColors.primaryColor,
            ),
            title: const Text('Email', style: AppTextStyles.subtitle),
            subtitle: Text(
              authService.getCurrentUser()?.email ?? 'Email não disponível',
              style: AppTextStyles.body,
            ),
          ),
          const Divider(height: 1, color: AppColors.dividerColor),
          ListTile(
            leading: const Icon(Icons.security, color: AppColors.primaryColor),
            title: const Text(
              'Senha de Transação',
              style: AppTextStyles.subtitle,
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.subtitle,
            ),
            onTap: () => Get.toNamed('/change-transaction-password'),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.dividerColor),
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(
              Icons.help_outline,
              color: AppColors.primaryColor,
            ),
            title: const Text('Ajuda', style: AppTextStyles.subtitle),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
            onTap: () {
              Get.snackbar(
                'Em breve',
                'Esta funcionalidade estará disponível em breve.',
              );
            },
          ),
          const Divider(height: 1, color: AppColors.dividerColor),
          ListTile(
            leading: const Icon(
              Icons.info_outline,
              color: AppColors.primaryColor,
            ),
            title: const Text(
              'Sobre o YeezyBank',
              style: AppTextStyles.subtitle,
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'YeezyBank',
                applicationVersion: '1.0.0',
                applicationLegalese:
                    '© 2025 YeezyBank. Todos os direitos reservados.',
                children: const [
                  SizedBox(height: 20),
                  Text(
                    'YeezyBank é um projeto acadêmico para demonstração de um aplicativo bancário utilizando Flutter e Firebase.',
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(AuthService authService) {
    return ElevatedButton(
      onPressed: () async {
        final confirm = await Get.dialog<bool>(
          _buildLogoutConfirmationDialog(),
        );
        if (confirm == true) {
          await authService.signOut();
          Get.offAllNamed('/login');
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.error,
        foregroundColor: AppColors.surface,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: AppTextStyles.button,
      ),
      child: const Text('Sair'),
    );
  }

  Widget _buildLogoutConfirmationDialog() {
    return AlertDialog(
      title: const Text('Sair da conta', style: AppTextStyles.title),
      content: const Text(
        'Tem certeza que deseja sair?',
        style: AppTextStyles.body,
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Get.back(result: true),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
          child: const Text('Sair', style: AppTextStyles.button),
        ),
        TextButton(
          onPressed: () => Get.back(result: false),
          child: const Text('Cancelar', style: AppTextStyles.button),
        ),
      ],
    );
  }
}
