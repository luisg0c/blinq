import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../domain/models/transaction_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Diálogo de confirmação de transação com código de segurança.
/// Apresenta detalhes da transação e solicita código para confirmar.
class TransactionConfirmationDialog extends StatefulWidget {
  final TransactionModel transaction;
  final String receiverEmail;

  const TransactionConfirmationDialog({
    Key? key,
    required this.transaction,
    required this.receiverEmail,
  }) : super(key: key);

  @override
  State<TransactionConfirmationDialog> createState() => _TransactionConfirmationDialogState();
}

class _TransactionConfirmationDialogState extends State<TransactionConfirmationDialog> {
  final TextEditingController _codeController = TextEditingController();
  bool _isConfirming = false;
  String? _errorMessage;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: AppColors.backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Confirmar Transferência',
              style: AppTextStyles.title.copyWith(fontSize: 20),
            ),
            const SizedBox(height: 16),
            Text(
              'Para sua segurança, confirme os detalhes da transferência:',
              style: AppTextStyles.body,
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Destinatário:', widget.receiverEmail),
            _buildInfoRow('Valor:', 'R\$ ${widget.transaction.amount.toStringAsFixed(2)}'),
            _buildInfoRow('Data:', _formatDate(widget.transaction.timestamp)),
            const SizedBox(height: 24),
            Text(
              'Digite o código de confirmação:',
              style: AppTextStyles.body,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(letterSpacing: 8, fontSize: 20),
              decoration: InputDecoration(
                hintText: '------',
                hintStyle: TextStyle(letterSpacing: 8, fontSize: 20, color: AppColors.hintColor),
                errorText: _errorMessage,
                errorStyle: const TextStyle(color: AppColors.error),
                counterText: '', // Remove o contador de caracteres
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.dividerColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primaryColor),
                ),
                filled: true, 
                fillColor: AppColors.surface,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isConfirming ? null : () => Get.back(result: false),
                  child: Text('Cancelar', style: TextStyle(color: AppColors.textColor)),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _isConfirming ? null : () {
                    if (_validateCode()) {
                      Get.back(result: true);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: AppColors.surface,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isConfirming
                    ? const SizedBox(
                        width: 20, 
                        height: 20, 
                        child: CircularProgressIndicator(
                          strokeWidth: 2, 
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.surface)
                        )
                      )
                    : const Text('Confirmar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(color: AppColors.subtitle),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')}';
  }

  bool _validateCode() {
    if (_codeController.text.trim().length != 6) {
      setState(() => _errorMessage = 'Código inválido');
      return false;
    }
    setState(() => _errorMessage = null);
    return true;
  }
}