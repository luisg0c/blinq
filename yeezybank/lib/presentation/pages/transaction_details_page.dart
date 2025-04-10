import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../domain/models/transaction_model.dart';
import '../../domain/services/auth_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../../domain/services/transaction_service.dart';

class TransactionDetailsPage extends StatefulWidget {
  final TransactionModel transaction;
  
  const TransactionDetailsPage({
    Key? key,
    required this.transaction,
  }) : super(key: key);

  @override
  State<TransactionDetailsPage> createState() => _TransactionDetailsPageState();
}

class _TransactionDetailsPageState extends State<TransactionDetailsPage> {
  final AuthService _authService = Get.find<AuthService>();
  final TransactionService _transactionService = Get.find<TransactionService>();
  
  bool _isGeneratingPdf = false;
  String? _senderEmail;
  String? _receiverEmail;
  
  @override
  void initState() {
    super.initState();
    _loadEmails();
  }
  
  Future<void> _loadEmails() async {
    try {
      // Se a transação é de tipo transfer, carregamos ambos os emails
      if (widget.transaction.type == 'transfer') {
        final currentUser = _authService.getCurrentUser();
        
        if (currentUser?.email != null) {
          setState(() {
            _senderEmail = currentUser!.email!;
          });
        }
        
        // Carregar email do destinatário se for uma transferência enviada
        if (widget.transaction.senderId == _authService.getCurrentUserId()) {
          final receiverAccount = await _transactionService.getReceiverInfo(widget.transaction.receiverId);
          if (receiverAccount != null) {
            setState(() {
              _receiverEmail = receiverAccount.email;
            });
          }
        } 
        // Carregar email do remetente se for uma transferência recebida
        else if (widget.transaction.receiverId == _authService.getCurrentUserId()) {
          final senderAccount = await _transactionService.getSenderInfo(widget.transaction.senderId);
          if (senderAccount != null) {
            setState(() {
              _senderEmail = senderAccount.email;
              _receiverEmail = currentUser?.email;
            });
          }
        }
      } 
      // Se for depósito, é o mesmo usuário
      else if (widget.transaction.type == 'deposit') {
        final currentUser = _authService.getCurrentUser();
        if (currentUser?.email != null) {
          setState(() {
            _senderEmail = currentUser!.email!;
            _receiverEmail = currentUser.email!;
          });
        }
      }
    } catch (e) {
      print('Erro ao carregar emails: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTransfer = widget.transaction.type == 'transfer';
    final isReceived = isTransfer && widget.transaction.receiverId == _authService.getCurrentUserId();
    final isSent = isTransfer && widget.transaction.senderId == _authService.getCurrentUserId();
    final isDeposit = widget.transaction.type == 'deposit';
    
    // Determinar as propriedades visuais da transação
    TransactionTypeInfo displayInfo = _getTransactionTypeInfo(isDeposit, isReceived, isSent);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(displayInfo.title, style: AppTextStyles.appBarTitle),
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: AppColors.textColor),
        actions: [
          if (isTransfer) // Compartilhar apenas transferências
            IconButton(
              icon: const Icon(Icons.share, color: AppColors.textColor),
              onPressed: _isGeneratingPdf ? null : _generateAndSharePdf,
              tooltip: 'Compartilhar comprovante',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card principal
            Card(
              color: AppColors.surface,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.dividerColor),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ícone e valor
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: displayInfo.color.withOpacity(0.2),
                          radius: 20,
                          child: Icon(displayInfo.icon, color: displayInfo.color, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [                            
                            Text(
                              displayInfo.title,
                              style: AppTextStyles.title.copyWith(
                                color: AppColors.textColor),
                            ),
                            Text(
                              DateFormat('dd/MM/yyyy - HH:mm:ss').format(widget.transaction.timestamp),
                              style: AppTextStyles.subtitle,
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(widget.transaction.amount),
                          style: AppTextStyles.title.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    
                    const Divider(height: 32, color: AppColors.dividerColor),
                    
                    // Detalhes da transação
                    if (isTransfer) ...[
                      _buildDetailRow('Tipo:', 'Transferência PIX'),
                      if (isSent) _buildDetailRow('De:', _senderEmail ?? 'Carregando...'),
                      if (isSent) _buildDetailRow('Para:', _receiverEmail ?? 'Carregando...'),
                      if (isReceived) _buildDetailRow('De:', _senderEmail ?? 'Carregando...'),
                      if (isReceived) _buildDetailRow('Para:', _receiverEmail ?? 'Carregando...'),
                    ],
                    
                    if (isDeposit) ...[
                      _buildDetailRow('Tipo:', 'Depósito'),
                      _buildDetailRow('Para:', _senderEmail ?? 'Carregando...'),
                    ],
                    
                    _buildDetailRow('Data/Hora:', DateFormat('dd/MM/yyyy - HH:mm:ss').format(widget.transaction.timestamp)),
                    _buildDetailRow('ID da Transação:', widget.transaction.id.substring(0, math.min(8, widget.transaction.id.length))),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Seção de autenticação
            if (widget.transaction.transactionToken != null)
              Card(
                color: AppColors.surface,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.dividerColor),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.lock, color: AppColors.primaryColor),
                          const SizedBox(width: 8),
                          const Text('Autenticação', style: AppTextStyles.subtitle),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.copy, size: 18),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(
                                text: widget.transaction.transactionToken!,
                              ));
                              Get.snackbar(
                                'Copiado', 'Código de autenticação copiado para a área de transferência',
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            },
                            tooltip: 'Copiar código',
                          ),
                        ],
                      ),
                    
                      const SizedBox(height: 12),

                      Text(
                        'Código de autenticação:',
                        style: AppTextStyles.body.copyWith(color: AppColors.subtitle),
                      ),

                      const SizedBox(height: 4),
                      SelectableText(
                        widget.transaction.transactionToken!,
                        style: AppTextStyles.body.copyWith(fontFamily: 'monospace', fontWeight: FontWeight.bold),
                      ),
                    
                      if (widget.transaction.status != null) ...[
                        const SizedBox(height: 16),
                        _buildStatusChip(widget.transaction.status.toString().split('.').last),
                      ],
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: AppTextStyles.subtitle),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    String label;

    switch (status) {
      case 'completed':
        chipColor = AppColors.success;
        label = 'Concluída';
        break;
      case 'confirmed':
        chipColor = AppColors.primaryColor;
        label = 'Confirmada';
        break;
      case 'pending':
        chipColor = AppColors.secondaryColor;
        label = 'Pendente';
        break;
      case 'failed':
        chipColor = AppColors.error;
        label = 'Falha';
        break;
      default:
        chipColor = AppColors.hintColor;
        label = status;
    }

    return Chip(
      backgroundColor: chipColor.withOpacity(0.1),
      side: BorderSide(color: chipColor.withOpacity(0.3)),
      label: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: chipColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
      avatar: CircleAvatar(
        backgroundColor: chipColor,
        radius: 8,
        child: const SizedBox(),
      ),
    );
  }

  // Método para determinar as propriedades visuais da transação
  TransactionTypeInfo _getTransactionTypeInfo(bool isDeposit, bool isReceived, bool isSent) {
    if (isDeposit) {
      return TransactionTypeInfo(
        title: 'Depósito',
        icon: Icons.add_circle_outline,
        color: AppColors.primaryColor,
      );
    } else if (isReceived) {
      return TransactionTypeInfo(
        title: 'Pix Recebido',
        icon: Icons.arrow_downward,
        color: AppColors.success,
      );
    } else if (isSent) {
      return TransactionTypeInfo(
        title: 'Pix Enviado',
        icon: Icons.arrow_upward,
        color: AppColors.error,
      );
    } else {
      return TransactionTypeInfo(
        title: 'Transação',
        icon: Icons.swap_horiz,
        color: AppColors.subtitle,
      );
    }
  }

  Future<void> _generateAndSharePdf() async {
    if (_isGeneratingPdf) return;

    setState(() {
      _isGeneratingPdf = true;
    });

    try {
      // Lógica para gerar e compartilhar PDF aqui
      // ...
      
      // Exemplo simplificado
      Get.snackbar(
        'Sucesso', 
        'Comprovante gerado com sucesso',
        backgroundColor: AppColors.success.withOpacity(0.2),
        colorText: AppColors.success,
      );
    } catch (e) {
      Get.snackbar(
        'Erro', 
        'Não foi possível gerar o comprovante: $e',
        backgroundColor: AppColors.error.withOpacity(0.2),
        colorText: AppColors.error,
      );
    } finally {
      setState(() {
        _isGeneratingPdf = false;
      });
    }
  }
}

// Classe auxiliar para informações de tipo de transação
class TransactionTypeInfo {
  final String title;
  final IconData icon;
  final Color color;
  
  TransactionTypeInfo({
    required this.title,
    required this.icon,
    required this.color,
  });
}