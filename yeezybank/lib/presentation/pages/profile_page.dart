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
          backgroundColor: AppColors.primaryColor.withOpacity(0.2),
          child: Icon(Icons.person, size: 40, color: AppColors.primaryColor),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Olá,', style: AppTextStyles.body),
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
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.email_outlined, color: AppColors.primaryColor),
            title: const Text('Email', style: AppTextStyles.subtitle),
            subtitle: Text(authService.getCurrentUser()?.email ?? 'Email não disponível', style: AppTextStyles.body),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.security, color: AppColors.primaryColor),
            title: const Text('Senha de Transação', style: AppTextStyles.subtitle),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
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
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.help_outline, color: AppColors.primaryColor),
            title: const Text('Ajuda', style: AppTextStyles.subtitle),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            onTap: () {
              Get.snackbar('Em breve', 'Esta funcionalidade estará disponível em breve.');
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.info_outline, color: AppColors.primaryColor),
            title: const Text('Sobre o YeezyBank', style: AppTextStyles.subtitle),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'YeezyBank',
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2025 YeezyBank. Todos os direitos reservados.',
                children: const [
                  SizedBox(height: 20),
                  Text('YeezyBank é um projeto acadêmico para demonstração de um aplicativo bancário utilizando Flutter e Firebase.'),
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
        final confirm = await Get.dialog<bool>(_buildLogoutConfirmationDialog());
        if (confirm == true) {
          await authService.signOut();
          Get.offAllNamed('/login');
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: AppTextStyles.button,
      ),
      child: const Text('Sair'),
    );
  }

  Widget _buildLogoutConfirmationDialog() {
    return AlertDialog(
      title: const Text('Sair da conta'),
      content: const Text('Tem certeza que deseja sair?'),
      actions: [
        TextButton(
          onPressed: () => Get.back(result: false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () => Get.back(result: true),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Sair'),
        ),
      ],
    );
  }
}
            ),
            const SizedBox(height: 20),
            Text(
              user?.email ?? 'Usuário Anônimo',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            
            // Informações do usuário
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.email_outlined, color: Color(0xFF388E3C)),
                    title: const Text('Email'),
                    subtitle: Text(user?.email ?? 'Email não disponível'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.security, color: Color(0xFF388E3C)),
                    title: const Text('Senha de Transação'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => Get.toNamed('/change-transaction-password'),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Seção de configurações
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.help_outline, color: Color(0xFF388E3C)),
                    title: const Text('Ajuda'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // Futura implementação de uma página de ajuda
                      Get.snackbar('Em breve', 'Esta funcionalidade estará disponível em breve.');
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.info_outline, color: Color(0xFF388E3C)),
                    title: const Text('Sobre o YeezyBank'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: 'YeezyBank',
                        applicationVersion: '1.0.0',
                        applicationLegalese: '© 2025 YeezyBank. Todos os direitos reservados.',
                        children: [
                          const SizedBox(height: 20),
                          const Text('YeezyBank é um projeto acadêmico para demonstração de um aplicativo bancário utilizando Flutter e Firebase.'),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            
            const Spacer(),
            
            // Botão de logout
            ElevatedButton.icon(
              onPressed: () async {
                final confirm = await Get.dialog<bool>(
                  AlertDialog(
                    title: const Text('Sair da conta'),
                    content: const Text('Tem certeza que deseja sair?'),
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
                
                if (confirm == true) {
                  await authService.signOut();
                  Get.offAllNamed('/login');
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text('Sair'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}