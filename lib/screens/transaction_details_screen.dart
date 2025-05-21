import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import '../core/theme.dart';
import '../models/transaction.dart';
import '../utils/formatters.dart';
import '../utils/pdf_generator.dart';
import '../services/auth_service.dart';
import '../services/transaction_service.dart';
import '../widgets/custom_button.dart';

class TransactionDetailsScreen extends StatefulWidget {
  final Transaction transaction;

  const TransactionDetailsScreen({
    Key? key,
    required this.transaction,
  }) : super(key: key);

  static const String routeName = '/transaction_details';

  @override
  State<TransactionDetailsScreen> createState() =>
      _TransactionDetailsScreenState();
}

class _TransactionDetailsScreenState extends State<TransactionDetailsScreen> {
  final _authService = AuthService();
  final _transactionService = TransactionService();
  bool _isGeneratingPdf = false;
  String? _counterpartyName;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final currentUser = await _authService.getCurrentUserModel();
    setState(() {
      _currentUserId = currentUser?.id;
    });

    if (widget.transaction.isTransfer) {
      final userId = widget.transaction.senderId == _currentUserId
          ? widget.transaction.receiverId
          : widget.transaction.senderId;

      if (userId != null) {
        final user = await _authService.getUserById(userId);
        setState(() {
          _counterpartyName = user?.name;
        });
      }
    }
  }

  Future<void> _generatePdf() async {
    setState(() {
      _isGeneratingPdf = true;
    });

    try {
      final pdfFile = await PdfGenerator.generateTransactionReceipt(
        transaction: widget.transaction,
        counterpartyName: _counterpartyName,
      );

      // Show success message with option to share
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Comprovante gerado com sucesso!'),
          action: SnackBarAction(
            label: 'Compartilhar',
            onPressed: () {
              // Share the PDF
              PdfGenerator.sharePdf(pdfFile);
            },
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao gerar comprovante: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isGeneratingPdf = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIncoming = widget.transaction.isDeposit ||
        (widget.transaction.isTransfer &&
            widget.transaction.receiverId == _currentUserId);
    final color = isIncoming ? AppColors.success : AppColors.error;
    final sign = isIncoming ? '+' : '-';
    final statusColor = widget.transaction.isCompleted
        ? AppColors.success
        : widget.transaction.isPending
            ? Colors.orange
            : Colors.red;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: color,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Detalhes da Transação',
          style: GoogleFonts.lexend(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Transaction Amount Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Valor',
                    style: GoogleFonts.lexend(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$sign${Formatters.formatCurrency(widget.transaction.amount)}',
                    style: GoogleFonts.lexend(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Transaction Details
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status
                  _buildDetailItem(
                    title: 'Status',
                    value: widget.transaction.isPending
                        ? 'Pendente'
                        : widget.transaction.isCompleted
                            ? 'Concluído'
                            : 'Falhou',
                    valueColor: statusColor,
                  ),

                  const Divider(height: 32),

                  // Type
                  _buildDetailItem(
                    title: 'Tipo',
                    value: widget.transaction.isDeposit
                        ? 'Depósito'
                        : 'Transferência',
                  ),

                  const SizedBox(height: 16),

                  // Date and Time
                  _buildDetailItem(
                    title: 'Data e Hora',
                    value:
                        Formatters.formatDateTime(widget.transaction.timestamp),
                  ),

                  if (widget.transaction.isTransfer) ...[
                    const SizedBox(height: 16),

                    // From/To
                    _buildDetailItem(
                      title: isIncoming ? 'De' : 'Para',
                      value: _counterpartyName ?? 'Carregando...',
                    ),
                  ],

                  if (widget.transaction.description != null &&
                      widget.transaction.description!.isNotEmpty) ...[
                    const SizedBox(height: 16),

                    // Description
                    _buildDetailItem(
                      title: 'Descrição',
                      value: widget.transaction.description!,
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Transaction ID
                  _buildDetailItem(
                    title: 'ID da Transação',
                    value: widget.transaction.id,
                    isLongText: true,
                    onLongPress: () {
                      Clipboard.setData(
                          ClipboardData(text: widget.transaction.id));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'ID copiado para a área de transferência!')),
                      );
                    },
                  ),

                  const SizedBox(height: 40),

                  // Generate Receipt Button
                  CustomButton(
                    text: 'Gerar Comprovante',
                    icon: Icons.receipt_long_outlined,
                    onPressed: _isGeneratingPdf ? null : _generatePdf,
                    isLoading: _isGeneratingPdf,
                    isFullWidth: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required String title,
    required String value,
    Color? valueColor,
    bool isLongText = false,
    VoidCallback? onLongPress,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.lexend(
            fontSize: 14,
            color: AppColors.textLight,
          ),
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onLongPress: onLongPress,
          child: Text(
            value,
            style: GoogleFonts.lexend(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: valueColor ?? AppColors.text,
            ),
            overflow: isLongText ? TextOverflow.ellipsis : null,
          ),
        ),
      ],
    );
  }
}
