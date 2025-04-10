import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icons.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

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
    
    // Helper function to determine transaction type colors
    TransactionTypeColors getTransactionTypeColors() {
      if (isDeposit) {
        return TransactionTypeColors(AppColors.primaryColor, 'Depósito', Icons.add_circle_outline);
      } else if (isReceived) {
        return TransactionTypeColors(AppColors.success, 'Pix Recebido', Icons.arrow_downward);
      } else if (isSent) {
        return TransactionTypeColors(AppColors.error, 'Pix Enviado', Icons.arrow_upward);
      } else {
        return TransactionTypeColors(AppColors.subtitle, 'Transação', Icons.swap_horiz);
      }
    }

    final typeColors = getTransactionTypeColors();
    final icon = typeColors.icon;
    final color = typeColors.color;
    final title = typeColors.title;
    IconData icon;
    Color color;
    String title;
    
    if (isDeposit) {
      icon = Icons.add_circle_outline;
      color = Colors.blue;
      title = 'Depósito';
    } else if (isReceived) {
      icon = Icons.arrow_downward;
      color = Colors.green;
      title = 'Pix Recebido';
    } else if (isSent) {
      icon = Icons.arrow_upward;
      color = Colors.red;
      title = 'Pix Enviado';
    } else {
      icon = Icons.swap_horiz;
      color = Colors.grey;
      title = 'Transação';
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(title, style: AppTextStyles.appBarTitle),
        backgroundColor: AppColors.primaryColor,
        iconTheme: IconThemeData(color: AppColors.textColor),
        actions: [
          if (isTransfer) // Compartilhar apenas transferências
            IconButton(
              icon: Icon(Icons.share, color: AppColors.textColor),
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
                side: BorderSide(color: AppColors.dividerColor),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ícone e valor
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: typeColors.color.withOpacity(0.2),
                          radius: 20,
                          child: Icon(icon, color: color, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [                            
                            Text(
                                title,
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
                    
                    Divider(height: 32, color: AppColors.dividerColor),
                    
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
                    _buildDetailRow('ID da Transação:', widget.transaction.id.substring(0, 8)),
                  ]),
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
                side: BorderSide(color: AppColors.dividerColor),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lock, color: AppColors.primaryColor),
                        const SizedBox(width: 8),
                        Text('Autenticação', style: AppTextStyles.subtitle),
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
            child: Text(value,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  } 

  Widget _buildStatusChip(String status) {
    Color color;
    String label;

      switch (status) {
      case 'completed':
        color = AppColors.success;
        label = 'Concluída';
        break;
      case 'confirmed':
        color = AppColors.primaryColor;
        label = 'Confirmada';
        break;
    case 'pending':
        color = AppColors.secondaryColor;
        label = 'Pendente';
        break;
      case 'failed':
        color = AppColors.error;
        label = 'Falha';
        break;
      default:
        color = AppColors.hintColor;
        label = status;
    }

    return Chip(
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color.withOpacity(0.3)),
      label: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
      ),
      avatar: CircleAvatar(
        backgroundColor: color,
        radius: 8,
        child: const SizedBox(),
      ),
    );
  } 

  Future<void> _generateAndSharePdf() async {
    if (_isGeneratingPdf) return;

    setState(() {
      _isGeneratingPdf = true;
    });

    try {
      // Gerar PDF
      final pdf = pw.Document();

      final isReceived = widget.transaction.receiverId == _authService.getCurrentUserId();
      final isSent = widget.transaction.senderId == _authService.getCurrentUserId();
      
      // Definir título
      String title = 'Comprovante de Transferência';
      if (isReceived) {
        title = 'Comprovante de Transferência Recebida';
      } else if (isSent) {
        title = 'Comprovante de Transferência Enviada';
      }
      
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Cabeçalho
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'YeezyBank', style: pw.TextStyle(
                        color: PdfColor.fromHex('556B2F'),
                        fontSize: 22,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      DateFormat('dd/MM/yyyy').format(DateTime.now()),
                      style: const pw.TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                
                pw.SizedBox(height: 20),
                
                // Título do comprovante
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey200,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Text(
                    title,
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                
                pw.SizedBox(height: 20),
                
                // Valor
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.symmetric(vertical: 16),
                  child: pw.Column(
                    children: [
                      pw.Text(
                        'Valor',
                        style: const pw.TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        'R\$ ${widget.transaction.amount.toStringAsFixed(2)}',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                
                pw.SizedBox(height: 20),
                
                // Detalhes da transferência
                pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _buildPdfRow('Data/Hora:', DateFormat('dd/MM/yyyy - HH:mm:ss').format(widget.transaction.timestamp)),
                      
                      pw.SizedBox(height: 12),
                      _buildPdfRow('De:', _senderEmail ?? 'Não disponível'),
                      
                      pw.SizedBox(height: 12),
                      _buildPdfRow('Para:', _receiverEmail ?? 'Não disponível'),
                      
                      pw.SizedBox(height: 12),
                      _buildPdfRow('ID da Transação:', widget.transaction.id),
                      
                      pw.SizedBox(height: 12),
                      _buildPdfRow('Autenticação:', widget.transaction.transactionToken ?? 'Não disponível'),
                    ],
                  )
                ),
                
                pw.SizedBox(height: 30),
                
                // Mensagem de confirmação
                pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.green50,
                      borderRadius: pw.BorderRadius.circular(8),
                    border: pw.Border.all(color: PdfColors.green),
                  ),
                  child: pw.Row(
                    children: [
                      pw.Container(
                        width: 24,
                        height: 24,
                        decoration: const pw.BoxDecoration(
                          color: PdfColors.green,
                          shape: pw.BoxShape.circle,
                        ),
                        child: pw.Center(
                          child: pw.Text(
                            '✓',
                            style: const pw.TextStyle(
                              color: PdfColors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      pw.SizedBox(width: 12),
                      pw.Expanded(
                        child: pw.Text(
                          'Esta transação foi processada e confirmada pelo YeezyBank.',
                          style: const pw.TextStyle(
                            color: PdfColors.green900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                pw.Spacer(),
                
                // Rodapé
                pw.Divider(),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Este comprovante é um documento válido.',
                  style: const pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey700,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
              ],
            );
          },
        ),
      );
      

        // Salvar PDF
        final output = await getTemporaryDirectory();
        final file = File('${output.path}/comprovante_${DateFormat('ddMMyyyyHHmmss').format(DateTime.now())}.pdf');
        await file.writeAsBytes(await pdf.save());
      // Compartilhar PDF
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Comprovante de Transferência YeezyBank',
      );
    } catch (e) {
      Get.snackbar(
        'Erro', 
        'Não foi possível gerar o comprovante: $e',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
    } finally {
      setState(() {
        _isGeneratingPdf = false;
      });
    }
  }
  
  pw.Widget _buildPdfRow(String label, String value) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 100,
          child: pw.Text(
            label,
            style: const pw.TextStyle(
              color: PdfColors.grey700,
            ),
          ),
        ),
        pw.Expanded(
          child: pw.Text(
            value,
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  } 
}

class TransactionTypeColors {
  final Color color;
  final String title;
  final IconData icon;
  TransactionTypeColors(this.color, this.title, this.icon);
}
}